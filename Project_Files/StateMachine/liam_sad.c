#include <bcm2835.h>
#include <stdio.h>
#include <unistd.h>
#include <time.h>

#define NUM_ROWS 4
#define NUM_COLS 4
const int ROWS[NUM_ROWS] = {20, 21, 22, 23};
const int COLS[NUM_COLS] = {24, 25, 26, 27};
#define CH_START 10
#define CH_END 17

const char *matrix[2][NUM_ROWS][NUM_COLS] = {
    {{"1", "2", "3", "A"}, {"4", "5", "6", "B"}, {"7", "8", "9", "C"}, {"*", "0", "#", "D"}},
    {{"31", "32", "33", "41"}, {"34", "35", "36", "42"}, {"37", "38", "39", "43"}, {"*", "30", "#", "44"}}
};

const uint8_t binary_values[16] = {
    0b00000000, 0b00000001, 0b00000010, 0b00000011,
    0b00000100, 0b00000101, 0b00000110, 0b00000111,
    0b00001000, 0b00001001, 0b00001010, 0b00001011,
    0b00001100, 0b00001101, 0b00001110, 0b00001111
};

void debounce() {
    usleep(500000);
}

void initialize() {
    debounce();
    for (int i = 0; i < NUM_ROWS; i++) {
        bcm2835_gpio_fsel(ROWS[i], BCM2835_GPIO_FSEL_OUTP);
        bcm2835_gpio_write(ROWS[i], LOW);
    }
    for (int i = 0; i < NUM_COLS; i++) {
        bcm2835_gpio_set_pud(COLS[i], BCM2835_GPIO_PUD_DOWN);
    }
    for (int ch = CH_START; ch < CH_END; ch++) {
        bcm2835_gpio_fsel(ch, BCM2835_GPIO_FSEL_OUTP);
    }
}

void setBinary(uint8_t value) {
    if (value < sizeof(binary_values)) {
        uint8_t binary = binary_values[value];
        for (int ch = CH_START; ch < CH_END; ch++) {
            bcm2835_gpio_write(ch, (binary >> (ch - CH_START)) & 1);
        }
    }
}

int main() {
    if (!bcm2835_init()) return 1;

    initialize();
    char current_matrix = 0; // 0 for normal, 1 for alternate
    const char *key_pressed = NULL;
    int last_key_value = -1; // To store the last key value
    int last_key_output = 0; // To store the last output value
    int mode_changed = 0; // Flag to ensure mode change is only registered once

    // Timing variables
    struct timespec last_output_time;
    struct timespec last_40_time;
    int output_state = 0; // 0 for last key output, 1 for "40"
    int last_key_output_time = 0; // Time since last key output

    printf("\nDecode mode is %s\n", current_matrix ? "ON" : "OFF");

    while (1) {
        int key_detected = 0; // Flag to check if a key is currently pressed

        for (int row = 0; row < NUM_ROWS; row++) {
            bcm2835_gpio_write(ROWS[row], HIGH);
            for (int col = 0; col < NUM_COLS; col++) {
                if (bcm2835_gpio_lev(COLS[col])) { // Key pressed
                    key_pressed = matrix[current_matrix][row][col];
                    key_detected = 1; // Set key detected flag

                    // Handle mode change with the '#' key
                    if (*key_pressed == '#') {
                        if (!mode_changed) { // Only change mode once per press
                            current_matrix = !current_matrix;
                            printf("\n\nDecode mode is %s\n", current_matrix ? "ON" : "OFF");
                            mode_changed = 1; // Set flag to prevent further mode changes until released
                        }
                    } else if (*key_pressed == '*') {
                        // Reset all variables and clear screen
                        system("clear");
                        current_matrix = 0;
                        printf("\nDecode mode is %s\n", current_matrix ? "ON" : "OFF");
                        last_key_value = -1; // Reset last key value
                        last_key_output = 0; // Reset last output value
                        last_key_output_time = 0; // Reset last key output time
                        mode_changed = 0; // Reset mode change flag
                    } else {
                        // Output the ASCII decode or numeric equivalent
                        last_key_value = (*key_pressed >= '0' && *key_pressed <= '9') ? *key_pressed - '0' : *key_pressed - 'A' + 10;
                        last_key_output = last_key_value; // Store last output value
                        printf("\r%s            ", key_pressed);
                        fflush(stdout);
                        setBinary(last_key_value);

                        // Update the last output time
                        clock_gettime(CLOCK_MONOTONIC, &last_output_time);
                        last_key_output_time = 0; // Reset last key output time since a key is pressed
                    }
                    debounce();
                }
            }
            bcm2835_gpio_write(ROWS[row], LOW);
        }

        // If no key is detected, handle output of last value
        if (!key_detected) {
            if (last_key_value != -1) { // If there was a last key value
                // Check how much time has passed since the last key output
                struct timespec current_time;
                clock_gettime(CLOCK_MONOTONIC, &current_time);
                long elapsed_time = (current_time.tv_sec - last_output_time.tv_sec) * 1000LL +
                                    (current_time.tv_nsec - last_output_time.tv_nsec) / 1000000;

                // Output the last key value for 2 seconds
                if (elapsed_time < 2000) {
                    printf("\r%d            ", last_key_output); // Output the last value
                    fflush(stdout);
                } else if (elapsed_time >= 2000 && output_state == 0) {
                    // Switch to outputting "40"
                    printf("\r40            "); // Output "40"
                    fflush(stdout);
                    output_state = 1; // Switch to "40" state
                    last_key_output_time = 0; // Reset last key output time
                    last_40_time = current_time; // Store current time for "40"
                }

                // Check if 0.5 seconds have passed since outputting "40"
                if (output_state == 1) {
                    long elapsed_40_time = (current_time.tv_sec - last_40_time.tv_sec) * 1000LL +
                                            (current_time.tv_nsec - last_40_time.tv_nsec) / 1000000;

                    if (elapsed_40_time >= 500) {
                        output_state = 0; // Reset state to output last key value again
                    }
                }
            }
        } else {
            // Reset the mode change flag if a key is pressed
            mode_changed = 0;
        }
    }

    bcm2835_close();
    return 0;
}
