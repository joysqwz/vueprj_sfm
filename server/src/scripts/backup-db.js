import { execSync } from "child_process"
import dotenv from "dotenv"
import path from "path"
import fs from "fs"

dotenv.config()

function getTimestamp() {
	const now = new Date()
	return now.toISOString().replace(/[:.]/g, "-")
}

const backupDir = "db_backups"
if (!fs.existsSync(backupDir)) {
	fs.mkdirSync(backupDir, { recursive: true })
}

const backupFileName = `backup-dump-${getTimestamp()}.sql`
const backupFile = path.join(backupDir, backupFileName)
const containerName = "vueprj_db_1"

try {
	console.log("[BACKUP] Проверка подключения к базе...")
	execSync(
		`docker exec ${containerName} psql -U ${process.env.DB_USER} -d ${process.env.DB_NAME} -c "SELECT 1"`,
		{ stdio: "inherit" }
	)

	console.log("[BACKUP] Создание бэкапа базы...")
	const containerBackupPath = "/tmp/backup.sql"
	execSync(
		`docker exec ${containerName} pg_dump -U ${process.env.DB_USER} -d ${process.env.DB_NAME} -f ${containerBackupPath}`
	)

	execSync(`docker cp ${containerName}:${containerBackupPath} ${backupFile}`)
	execSync(`docker exec ${containerName} rm ${containerBackupPath}`)

	console.log(`[BACKUP] Бэкап успешно сохранён в ${backupFile}`)
} catch (error) {
	console.error("[BACKUP] Ошибка при создании бэкапа:", error.message)
	process.exit(1)
}
