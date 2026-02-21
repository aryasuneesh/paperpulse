allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    plugins.withId("com.android.library") {
        val android = project.extensions.getByType(com.android.build.gradle.BaseExtension::class.java)
        if (android.namespace == null) {
            android.namespace = "com.paperpulse.${project.name.replace("-", "_")}"
        }
    }
    plugins.withId("com.android.application") {
        val android = project.extensions.getByType(com.android.build.gradle.BaseExtension::class.java)
        if (android.namespace == null) {
            android.namespace = "com.paperpulse.${project.name.replace("-", "_")}"
        }
    }

    // Surgical fix for AGP 8+ manifest package attribute error
    val fixManifestTask = tasks.register("fixManifest") {
        doLast {
            val manifestFile = File(projectDir, "src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val content = manifestFile.readText()
                if (content.contains("package=")) {
                    val newContent = content.replace(Regex("package=\"[^\"]*\""), "")
                    manifestFile.writeText(newContent)
                }
            }
        }
    }

    plugins.withId("com.android.library") {
        tasks.named("preBuild") {
            dependsOn(fixManifestTask)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
