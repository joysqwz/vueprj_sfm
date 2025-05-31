import { execSync } from "child_process"
import path from "path"
import dotenv from "dotenv"

dotenv.config()

const dumpFile = process.argv[2]
if (!dumpFile) {
	console.error("Укажите путь к SQL дампу.")
	process.exit(1)
}

const absolutePath = path.resolve(dumpFile)
const containerName = " vueprj_db_1"
const containerDumpPath = `/tmp/${path.basename(absolutePath)}`

try {
	console.log("[RESTORE] Проверка подключения к базе...")
	execSync(
		`docker exec ${containerName} psql -U ${process.env.DB_USER} -d ${process.env.DB_NAME} -c "SELECT 1"`,
		{ stdio: "inherit" }
	)

	console.log("[RESTORE] Копируем дамп в контейнер...")
	execSync(
		`docker cp ${absolutePath} ${containerName}:${containerDumpPath}`,
		{ stdio: "inherit" }
	)

	const dropSchemaSql = `DROP SCHEMA public CASCADE; CREATE SCHEMA public;`

	console.log("[RESTORE] Очистка схемы public...")
	execSync(
		`docker exec ${containerName} psql -U ${process.env.DB_USER} -d ${process.env.DB_NAME} -c "${dropSchemaSql}"`,
		{ stdio: "inherit" }
	)

	console.log("[RESTORE] Восстановление базы из дампа: " + containerDumpPath)
	execSync(
		`docker exec ${containerName} psql -U ${process.env.DB_USER} -d ${process.env.DB_NAME} -f "${containerDumpPath}"`,
		{ stdio: "inherit" }
	)

	console.log("[RESTORE] Удаляем дамп из контейнера...")
	execSync(
		`docker exec ${containerName} rm "${containerDumpPath}"`,
		{ stdio: "inherit" }
	)

	console.log("[RESTORE] Восстановление базы завершено успешно.")
	console.log(`База восстановлена успешно из: ${absolutePath}`)
} catch (error) {
	console.error("[RESTORE] Ошибка при восстановлении базы:", error.message)
	process.exit(1)
}
