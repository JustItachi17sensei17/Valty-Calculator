# 🌌 Valty Shell Calculator (Valty OS)

> **Professional-grade Scientific CLI Calculator & Physics Solver**
> Optimized for Science Students (Thanaweya Amma Curriculum)

---

## 🚀 Overview

Valty OS is not just a calculator; it's a high-performance terminal-based operating environment designed for high school and college science students. It combines a robust mathematical engine with a deep understanding of physics, chemistry, and engineering units.

<img width="461" height="245" alt="image" src="https://github.com/user-attachments/assets/33c87252-e5fc-43a1-b7d4-42f507e15031" />


## ✨ Key Features

### 🧮 Advanced Mathematical Engine
*   **Fluent Logic**: Supports implicit multiplication (e.g., `2pi`, `2(3+4)`, `2sin30`).
*   **High Precision**: Powered by `bc` and `awk` with up to 20 decimal places.
*   **Scientific Range**: Handles values from $10^{-100}$ to $10^{100}$ with automatic scientific notation switching.
*   **Fractional Powers**: Native support for roots and fractional exponents (e.g., `27^(1/3)`).

### 🔄 Professional Unit Converter
*   **SI Prefixes**: Support from **Femto** ($10^{-15}$) to **Tera** ($10^{12}$).
*   **Offset Logic**: Specialized engine for Temperature conversions (°C, °F, K, °R).
*   **10+ Categories**: Electricity, Mechanics, Pressure, Data Storage, Time, Area, and more.
*   **Smart "Ans"**: Use your last calculation result directly in the converter.

### ⚛️ Physics Curriculum Solver
*   **Chapters 1-8**: Dedicated solvers for DC Circuits, Magnetism, Induction, AC Circuits, and Modern Physics.
*   **Constants**: Hardcoded curriculum-accurate constants ($c, h, G, N_a, k_b, q_e$).
*   **Meters Solver**: Specialized logic for Ammeters, Voltmeters, and Ohmmeters (Rs, Rm, Rx).

### 📈 Equation & Ratio Solvers
*   **Polynomials**: Solve Linear and Quadratic equations instantly.
*   **Simultaneous**: 2 and 3 unknown variables using Cramer's Determinant method.
*   **Proportions**: Solve $a/b = c/d$ with the `?` unknown operator.
*   **Simplifier**: Reduce ratios like `0.5:1:1.5` to `1:2:3`.

## 🎮 Interface & Shortcuts

The system uses a cyberpunk-themed ASCII interface with dedicated navigation keys:

| Key | Action |
| :--- | :--- |
| `[m]` | **Manual**: Detailed system documentation |
| `[u]` | **Units**: Launch the Professional Converter |
| `[e]` | **Equations**: Open the Physics & Math Solver |
| `[s]` | **Settings**: Toggle precision, angle mode (DEG/RAD), and format |
| `[y]` | **History**: View last 10 calculations |
| `[q]` | **Shutdown**: Safely terminate the session |

## 🛠️ Installation & Usage

1.  **Requirement**: Ensure you have `bash` (Git Bash on Windows) and `bc` or `awk` installed.
2.  **Run**:
    ```bash
    sh Calculator.sh
    ```

## 🕵️ Easter Eggs
The system contains several hidden modes. Try typing these at the main prompt and they will appear

---

**Developed by**: Antigravity (AI Architect)  
**Idea Founder**: Itachi Sensei 17  
**Status**: ONLINE ●
