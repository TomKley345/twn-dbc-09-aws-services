# 1. Schritt: Nutze ein schlankes Java 17 Laufzeit-Image
FROM eclipse-temurin:17-jre-alpine

# 2. Schritt: Setze das Arbeitsverzeichnis im Container
WORKDIR /app

# 3. Schritt: Kopiere die gebaute JAR-Datei in den Container
# (Achte darauf, dass der Name exakt zu deiner pom.xml passt!)
COPY target/java-maven-app-1.1.0-SNAPSHOT.jar app.jar

# 4. Schritt: Port 8080 für den Container freigeben
EXPOSE 3080

# 5. Schritt: Befehl zum Starten der Anwendung definieren
ENTRYPOINT ["java", "-jar", "app.jar"]
