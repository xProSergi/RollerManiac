buildscript {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal() // Asegúrate de tener este repositorio
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.0.2") // Reemplaza con la versión más reciente o recomendada
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.0.10") // Asegúrate de que la versión coincida con settings.gradle.kts
        classpath("com.google.gms:google-services:4.4.2") // Asegúrate de tener esta línea si usas Firebase
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}