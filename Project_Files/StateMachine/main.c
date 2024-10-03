#include <bcm2835.h>
#include <stdio.h>
#include <unistd.h> // for usleep
#include <fcntl.h>
#include <termios.h>
#include <sys/select.h>

// GPIO pin definitions for keypad
#define NUM_ROWS 4
#define NUM_COLS 4
const int ROWS[NUM_ROWS] = {20, 21, 22, 23};
const int COLS[NUM_COLS] = {24, 25, 26, 27};

// GPIO pin definitions for additional channels
#define ch0 10
#define ch1 11
#define ch2 12
#define ch3 13
#define ch4 14
#define ch5 15
#define ch6 16
#define ch7 17

// Keypad matrices
const char *matrix_normal[NUM_ROWS][NUM_COLS] = {
    {"1", "2", "3", "A"},
    {"4", "5", "6", "B"},
    {"7", "8", "9", "C"},
    {"*", "0", "#", "D"}};

const char *matrix_alt[NUM_ROWS][NUM_COLS] = {
    {"E", "F", "G", "N"},
    {"H", "I", "J", "O"},
    {"K", "L", "M", "P"},
    {"*", "R", "#", "Q"}};

u_int8_t binary = 0b01000000;

// Function prototypes
void initialize();
void debounce();

int main()
{
    if (!bcm2835_init())
    {
        printf("failed\n");
        return 1;
    }

    char input;

    // Set stdin to non-blocking mode
    struct termios old_term, new_term;
    tcgetattr(STDIN_FILENO, &old_term);
    new_term = old_term;
    new_term.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &new_term);
    int old_flags = fcntl(STDIN_FILENO, F_GETFL, 0);
    fcntl(STDIN_FILENO, F_SETFL, old_flags | O_NONBLOCK);

    initialize();
    printf("here papi");
    bcm2835_gpio_write(ch0, (binary >> 0) & 1);
    bcm2835_gpio_write(ch1, (binary >> 1) & 1);
    bcm2835_gpio_write(ch2, (binary >> 2) & 1);
    bcm2835_gpio_write(ch3, (binary >> 3) & 1);
    bcm2835_gpio_write(ch4, (binary >> 4) & 1);
    bcm2835_gpio_write(ch5, (binary >> 5) & 1);
    bcm2835_gpio_write(ch6, (binary >> 6) & 1);
    bcm2835_gpio_write(ch7, (binary >> 7) & 1);

    char current_matrix = 'n'; // 'n' for normal, 'a' for alternate
    printf("Decode mode is OFF\n");

    while (1)
    {
        char *key_pressed = NULL; // Initialize key_pressed to null

        // Iterate over rows
        for (int row = 0; row < NUM_ROWS; row++)
        {
            bcm2835_gpio_write(ROWS[row], HIGH); // Set current row to HIGH

            // Iterate over columns
            for (int col = 0; col < NUM_COLS; col++)
            {
                // Check if current column is pressed
                if (bcm2835_gpio_lev(COLS[col]))
                {
                    key_pressed = (current_matrix == 'n') ? matrix_normal[row][col] : matrix_alt[row][col];
                    debounce(); // Debounce

                    // Switch case to handle "A" key press
                    switch (*key_pressed)
                    {
                    case '1':
                        // Set binary equivalent of A

                        while(1) {
                            binary = 0b00000001; // Binary equivalent of A
                            bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                            bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                            bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                            bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                            bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                            bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                            bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                            bcm2835_gpio_write(ch7, (binary >> 7) & 1);

                            bcm2835_delay(2000);

                            binary = 0b01000000; 
                            bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                            bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                            bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                            bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                            bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                            bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                            bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                            bcm2835_gpio_write(ch7, (binary >> 7) & 1);

                            bcm2835_delay(500);

                            // Check for key press
                            fd_set rfds;
                            FD_ZERO(&rfds);
                            FD_SET(STDIN_FILENO, &rfds);
                            struct timeval tv = {0, 0};
                            printf("Waiting for input...\n");
                            if (select(STDIN_FILENO + 1, &rfds, NULL, NULL, &tv) > 0) {
                                printf("Input detected\n");
                                if (FD_ISSET(STDIN_FILENO, &rfds)) {
                                    read(STDIN_FILENO, &input, 1);
                                    printf("Input: %c\n", input);
                                    if (input != '1') // Assuming '7' is the key to break the loop
                                        break;
                                }
                            }
                        }

                    case '2':
                        // Set binary equivalent of A
                        binary = 0b00000010; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                    case '3':
                        // Set binary equivalent of A
                        binary = 0b00000011; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;
                    
                    case '4':
                        // Set binary equivalent of A
                        binary = 0b00000100; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                    
                    case '5':
                        // Set binary equivalent of A
                        binary = 0b00000101; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                    
                    case '6':
                        // Set binary equivalent of A
                        binary = 0b00000110; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                    
                    case '7':
                        // Set binary equivalent of A
                        binary = 0b00001110; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                    
                    case '8':
                        // Set binary equivalent of A
                        binary = 0b00001111; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                    
                    case '9':
                        // Set binary equivalent of A
                        binary = 0b00001001; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                    
                    case 'A':
                        // Set binary equivalent of A
                        binary = 0b00001010; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;
                                                    
                    case 'B': 
                        binary = 0b00001011; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;
                    
                    case 'C': 
                        binary = 0b00001100; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                    case 'D': 
                        binary = 0b00001101; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;
                    
                     case 'E':
                        // Set binary equivalent of A
                        binary = 0b00110001; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                     case 'F':
                        // Set binary equivalent of A
                        binary = 0b00110010; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;
                    
                     case 'G':
                        // Set binary equivalent of A
                        binary = 0b00110011; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                     case 'H':
                        // Set binary equivalent of A
                        binary = 0b00110100; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                     case 'I':
                        // Set binary equivalent of A
                        binary = 0b00110101; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                     case 'J':
                        // Set binary equivalent of A
                        binary = 0b00110110; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                    case 'K':
                        // Set binary equivalent of A
                        binary = 0b00110111; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                    case 'L':
                        // Set binary equivalent of A
                        binary = 0b00111000; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                    case 'M':
                        // Set binary equivalent of A
                        binary = 0b00111001; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                    case 'N':
                        // Set binary equivalent of A
                        binary = 0b01000001; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                    case 'O':
                        // Set binary equivalent of A
                        binary = 0b01000010; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                    case 'P':
                        // Set binary equivalent of A
                        binary = 0b01000011; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;

                    case 'Q':
                        // Set binary equivalent of A
                        binary = 0b01000100; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);

                        break;

                    case 'R':
                        // Set binary equivalent of A
                        binary = 0b00110000; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;
                    
                    case '0':
                        // Set binary equivalent of A
                        binary = 0b00000000; // Binary equivalent of A
                        bcm2835_gpio_write(ch0, (binary >> 0) & 1);
                        bcm2835_gpio_write(ch1, (binary >> 1) & 1);
                        bcm2835_gpio_write(ch2, (binary >> 2) & 1);
                        bcm2835_gpio_write(ch3, (binary >> 3) & 1);
                        bcm2835_gpio_write(ch4, (binary >> 4) & 1);
                        bcm2835_gpio_write(ch5, (binary >> 5) & 1);
                        bcm2835_gpio_write(ch6, (binary >> 6) & 1);
                        bcm2835_gpio_write(ch7, (binary >> 7) & 1);
                        break;
                    }

                    

                     
                    
                   
                        
                    
                        
                }
            }

            bcm2835_gpio_write(ROWS[row], LOW); // Reset current row to LOW
        }

        if (key_pressed && *key_pressed == '#')
        {
            current_matrix = (current_matrix == 'n') ? 'a' : 'n'; // Toggle matrix
            printf("Decode mode is %s\n", (current_matrix == 'n') ? "OFF" : "ON");
        }
        else if (key_pressed)
        { // Check if a valid key is pressed
            printf("%s\n", key_pressed);
        }
    }

    bcm2835_close();
    return 0;
}

void initialize()
{
    // Initialize GPIO pins for keypad rows
    for (int i = 0; i < NUM_ROWS; i++)
    {
        bcm2835_gpio_fsel(ROWS[i], BCM2835_GPIO_FSEL_OUTP);
        bcm2835_gpio_write(ROWS[i], LOW);
    }

    // Initialize GPIO pins for keypad columns
    for (int i = 0; i < NUM_COLS; i++)
    {
        bcm2835_gpio_fsel(COLS[i], BCM2835_GPIO_FSEL_INPT);
        bcm2835_gpio_set_pud(COLS[i], BCM2835_GPIO_PUD_DOWN);
    }

    // Initialize GPIO pins for additional channels (GPIO 10 - 17)
    bcm2835_gpio_fsel(ch0, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(ch1, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(ch2, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(ch3, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(ch4, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(ch5, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(ch6, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(ch7, BCM2835_GPIO_FSEL_OUTP);




}

void debounce() {
    usleep(500000);
}
