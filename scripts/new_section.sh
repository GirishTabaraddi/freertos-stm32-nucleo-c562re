#!/bin/bash
# new_section.sh — Create boilerplate for a new exercise
# Usage: bash scripts/new_section.sh 04 ex002 "Three Tasks with Notifications"

SECTION="${1}"
EXERCISE="${2}"
DESCRIPTION="${3}"

if [ -z "$SECTION" ] || [ -z "$EXERCISE" ] || [ -z "$DESCRIPTION" ]; then
    echo "Usage: $0 <section-number> <exercise-id> <description>"
    echo "Example: $0 04 ex002 'Three Tasks with Notifications'"
    exit 1
fi

# Find section directory
SECTION_DIR=$(find sections/ -maxdepth 1 -name "${SECTION}-*" -type d | head -1)
if [ -z "$SECTION_DIR" ]; then
    echo "❌ Section directory for '${SECTION}' not found"
    exit 1
fi

EXERCISE_DIR="${SECTION_DIR}/exercises/${EXERCISE}"
mkdir -p "${EXERCISE_DIR}/Core/Inc"
mkdir -p "${EXERCISE_DIR}/Core/Src"

# Create README for the exercise
cat > "${EXERCISE_DIR}/README.md" << EOF
# ${EXERCISE}: ${DESCRIPTION}

## Objective

<!-- What does this exercise teach? -->

## Hardware

- Board: NUCLEO-C562RE
- LED: LD2 (Green, PA5)
- Button: B1 (PC13)
- UART: USART2 → /dev/ttyACM0 @ 115200

## Key APIs Used

<!-- List FreeRTOS APIs demonstrated -->

## Expected Output

\`\`\`
<!-- Paste expected UART output here -->
\`\`\`

## SEGGER SystemView Analysis

<!-- What should you observe in SystemView? -->

## Notes

<!-- Any gotchas or learnings from this exercise -->
EOF

# Create stub main source file
cat > "${EXERCISE_DIR}/Core/Src/main.c" << EOF
/**
 * @file main.c
 * @brief ${DESCRIPTION}
 * @section ${SECTION}
 * @exercise ${EXERCISE}
 *
 * Board: NUCLEO-C562RE (STM32C562RE, Cortex-M33)
 */

#include "main.h"
#include "FreeRTOS.h"
#include "task.h"

/* ── Private function prototypes ─────────────────────────────────────────── */
static void SystemClock_Config(void);
static void MX_GPIO_Init(void);

/* ── Task handles ─────────────────────────────────────────────────────────── */

/* ── Task functions ───────────────────────────────────────────────────────── */

/* ── Main ─────────────────────────────────────────────────────────────────── */
int main(void) {
    HAL_Init();
    SystemClock_Config();
    MX_GPIO_Init();

    /* TODO: Create tasks here */

    vTaskStartScheduler();

    /* Should never reach here */
    while (1);
}

/* ── FreeRTOS hook implementations ───────────────────────────────────────── */
void vApplicationStackOverflowHook(TaskHandle_t xTask, char *pcTaskName) {
    (void)xTask;
    (void)pcTaskName;
    __disable_irq();
    while (1);
}

void vApplicationMallocFailedHook(void) {
    __disable_irq();
    while (1);
}
EOF

echo "✅ Exercise created: ${EXERCISE_DIR}"
echo ""
echo "NEXT STEPS:"
echo "  1. git checkout -b section/${SECTION}-$(basename $SECTION_DIR | cut -d'-' -f2-)"
echo "  2. Fill in ${EXERCISE_DIR}/Core/Src/main.c"
echo "  3. Fill in ${EXERCISE_DIR}/README.md"
echo "  4. git add && git commit"