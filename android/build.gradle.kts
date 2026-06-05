// build.gradle.kts

import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

// ---------------------------------------------
// Repositories & Classpath
// ---------------------------------------------
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.3.15")
    }
}

// ---------------------------------------------
// New Build Directory
// ---------------------------------------------
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.set(newBuildDir)

// ---------------------------------------------
// Subprojects build dirs
// ---------------------------------------------
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// ---------------------------------------------
// Clean task
// ---------------------------------------------
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}