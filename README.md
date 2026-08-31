# 💣 FPGA Bomb Defusal Game

<p align="center">
  <a href="https://www.youtube.com/watch?v=BdUq50Uujes">
    <img src="https://img.shields.io/badge/YouTube-Watch%20Demo-red?style=for-the-badge&logo=youtube" alt="Watch Demo on YouTube">
  </a>
</p>

<p align="center">
  <a href="https://www.youtube.com/watch?v=BdUq50Uujes">
    <img src="https://img.youtube.com/vi/BdUq50Uujes/maxresdefault.jpg" alt="FPGA Bomb Defusal Game - Watch Video">
  </a>
</p>

## 🎮 About

A **Verilog-based FPGA Bomb Defusal Game** where the player must guess a randomly generated **4-digit code** before the timer runs out.

### Difficulty Levels

| Difficulty |         Time |
| ---------- | -----------: |
| 🟢 Easy    | 120 seconds |
| 🟡 Medium  |  90 seconds |
| 🔴 Hard    |  60 seconds |

**SW7 + SW8**

* `00` → Easy
* `01` → Medium
* `10 / 11` → Hard

## 🕹️ Controls

* **[0] KEY** – Start game / submit digit
* **[1] KEY** – Restart game
* **Digit Input** – Enter a code digit
* **Green LEDs** – Indicate distance from the correct digit
* **7-Segment Display** – Timer and game status

Each incorrect guess deducts **5 seconds** from the timer.

After **4 correct digits**, the bomb is defused and `GOOD` is displayed.

If the timer reaches zero, `BANG` is displayed.

## 🛠️ Technologies

**Verilog HDL · FPGA · FSM · 7-Segment Display · LEDs · Digital Counters · Pseudo-Random Code Generation**
