# MyDesktopVideo

🌐 **Language / Idioma**:
[🇧🇷 Português (Brasil)](#-português-brasil) • [🇺🇸 English (US)](#-english-us)

---

## 🎬 Overview

A lightweight, performance-focused macOS application that plays videos as animated desktop wallpapers, running behind all windows and controlled entirely from the menu bar.

---

## 🌐 Português (Brasil)

<details open>
<summary><strong>Descrição</strong></summary>

Um aplicativo macOS leve que transforma qualquer vídeo em um papel de parede animado, funcionando diretamente da barra de menus. Projetado com foco total em desempenho, simplicidade e integração nativa com o sistema.

</details>

### ✨ Funcionalidades

* **Papel de Parede Animado**: Reproduz vídeos em loop atrás dos ícones do desktop
* **Persistência**: Lembra automaticamente do último vídeo selecionado
* **Multimonitor**: Sincronização do vídeo em todas as telas
* **Mudo / Som**: Controle de áudio com persistência de estado
* **Auto-start**: Inicia automaticamente ao fazer login no macOS
* **Barra de Menus**: Controle total via ícone 🎬, sem aparecer no Dock
* **Performance Otimizada**:

  * Reuso de player
  * Buffer curto
  * Codec adequado
  * Pausa inteligente para economia de CPU/GPU

### ▶ Demonstração

[https://github.com/user-attachments/assets/cb7cfe6b-78cc-41d0-b109-49e325934986](https://github.com/user-attachments/assets/cb7cfe6b-78cc-41d0-b109-49e325934986)

> *Vídeo de demonstração.*

### 📦 Requisitos

* macOS 13.0 ou superior (`SMAppService`)
* `clang++` (Xcode Command Line Tools)

### 🛠 Como Compilar (CMake)

```bash
# 1. Configurar o projeto
cmake -B build

# 2. Compilar
cmake --build build

# 3. Rodar o aplicativo
open build/MyDesktopVideo.app
```

### 💎 Formatação de Código

O projeto utiliza `clang-format` (estilo Allman) e as configurações estão no arquivo `.clang-format`. No VS Code, o "Format on Save" está habilitado.

```bash
# Formatar manualmente via terminal
clang-format -i src/main.mm
```

---

## 🌐 English (US)

<details>
<summary><strong>Description</strong></summary>

A lightweight macOS application that turns any video into an animated desktop wallpaper, running behind all windows and fully controlled from the menu bar. Built with a strong focus on performance and native system integration.

</details>

### ✨ Features

* **Animated Wallpaper**: Looped video playback behind desktop icons
* **Persistence**: Remembers the last selected video on restart
* **Multi-monitor**: Native multi-display synchronization
* **Mute / Sound**: Audio toggle with state persistence
* **Auto-start**: Launches automatically on macOS login
* **Menu Bar Control**: 🎬 icon only, no Dock presence
* **Optimized Performance**:

  * Player reuse
  * Short buffering
  * Proper codec usage
  * Smart pause to reduce CPU/GPU usage

### ▶ Demonstration

[https://github.com/user-attachments/assets/cb7cfe6b-78cc-41d0-b109-49e325934986](https://github.com/user-attachments/assets/cb7cfe6b-78cc-41d0-b109-49e325934986)

> *Demonstration video.*

### 📦 Requirements

* macOS 13.0 or newer (`SMAppService` support)
* `clang++` (Xcode Command Line Tools)
* `cmake`

### 🛠 How to Build (CMake)

```bash
# 1. Configure the project
cmake -B build

# 2. Build
cmake --build build

# 3. Run the application
open build/MyDesktopVideo.app
```

### 💎 Code Formatting

The project uses `clang-format` (Allman style) via the `.clang-format` file. VS Code is configured for **Format on Save**.

```bash
# Format manually via terminal
clang-format -i src/main.mm
```

---

## 📁 Project Structure

* `src/` — Objective-C++ source code (`main.mm`)
* `assets/` — Icons and static resources
* `build/` — Compiled application bundle (Git ignored)
* `.vscode/` — VS Code formatting settings
* `README.md` — Project documentation


---

## 📜 License

MIT License
