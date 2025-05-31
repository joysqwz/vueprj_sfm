import { execSync } from "child_process"
import path from "path"
import fs from "fs"
import dotenv from "dotenv"

dotenv.config()

const containerName = " vueprj_db_1"
const backupDir = path.resolve("db_backups")
if (!fs.existsSync(backupDir)) {
	fs.mkdirSync(backupDir, { recursive: true })
}

const timestamp = new Date().toISOString().replace(/[:.]/g, "-")
const backupFile = path.resolve(`${backupDir}/dump-${timestamp}.sql`)
const containerBackupPath = "/tmp/reset-backup.sql"
const dropSchemaSql = `DROP SCHEMA public CASCADE; CREATE SCHEMA public;`

try {
	console.log("[RESET] Проверка подключения к базе...")
	execSync(
		`docker exec ${containerName} psql -U ${process.env.DB_USER} -d ${process.env.DB_NAME} -c "SELECT 1"`,
		{ stdio: "inherit" }
	)

	console.log("[RESET] Создаем бэкап базы внутри контейнера...")
	execSync(
		`docker exec ${containerName} pg_dump -U ${process.env.DB_USER} -d ${process.env.DB_NAME} -F p -f ${containerBackupPath}`
	)

	console.log("[RESET] Копируем бэкап на хост...")
	execSync(`docker cp ${containerName}:${containerBackupPath} ${backupFile}`)

	console.log("[RESET] Удаляем временный бэкап из контейнера...")
	execSync(`docker exec ${containerName} rm ${containerBackupPath}`)

	console.log("[RESET] Очистка схемы public...")
	execSync(
		`docker exec ${containerName} psql -U ${process.env.DB_USER} -d ${process.env.DB_NAME} -c "${dropSchemaSql}"`,
		{ stdio: "inherit" }
	)

	console.log("[RESET] Копируем бэкап обратно в контейнер для восстановления...")
	execSync(`docker cp ${backupFile} ${containerName}:${containerBackupPath}`)

	console.log("[RESET] Восстановление базы из бэкапа...")
	execSync(
		`docker exec ${containerName} psql -U ${process.env.DB_USER} -d ${process.env.DB_NAME} -f ${containerBackupPath}`,
		{ stdio: "inherit" }
	)

	console.log("[RESET] Удаляем бэкап из контейнера после восстановления...")
	execSync(`docker exec ${containerName} rm ${containerBackupPath}`)

	console.log("[RESET] База сброшена и восстановлена успешно.")
	console.log(`База сброшена и восстановлена успешно из: ${backupFile}`)
} catch (error) {
	console.error("[RESET] Ошибка при сбросе базы:", error.message)
	process.exit(1)
}
