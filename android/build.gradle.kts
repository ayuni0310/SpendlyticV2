allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://developer.huawei.com/repo/") }
    }
}

buildscript {
    repositories {
        google()
        mavenCentral()
        // Add the Huawei Maven address
        maven { url = uri("https://developer.huawei.com/repo/") }
    }
    dependencies {
        // Add Huawei AG Connect plugin
        classpath("com.huawei.agconnect:agcp:1.5.2.300")
        classpath("com.google.gms:google-services:4.4.2")
        classpath("com.android.tools.build:gradle:8.1.0")
    }
}

// Relocate build directory
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// Ensure app module is evaluated first
subprojects {
    evaluationDependsOn(":app")
}

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
