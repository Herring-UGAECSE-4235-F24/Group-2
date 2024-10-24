#include <stdio.h>
#include <fcntl.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <time.h>

#define RTC_ADDRESS 0x68  // I2C address of the DS3231

// Convert BCD to decimal
int bcd_to_decimal(int bcd) {
    return (bcd / 16) * 10 + (bcd % 16);
}

void read_time(int file) {
    unsigned char buf[7];

    // Set register pointer to 0x00 (seconds register)
    buf[0] = 0x00;
    if (write(file, buf, 1) != 1) {
        perror("Failed to set register pointer");
        return;
    }

    // Read 7 bytes from the RTC starting at register 0x00
    if (read(file, buf, 7) != 7) {
        perror("Failed to read from the RTC");
        return;
    }

    // Extract and convert time data from BCD to decimal
    int seconds = bcd_to_decimal(buf[0] & 0x7F);
    int minutes = bcd_to_decimal(buf[1] & 0x7F);
    int hours = bcd_to_decimal(buf[2] & 0x3F);  // 24-hour format
    int day = bcd_to_decimal(buf[4]);
    int month = bcd_to_decimal(buf[5] & 0x1F);
    int year = bcd_to_decimal(buf[6]) + 2024;

    // Print the current time
    printf("Current time: %04d-%02d-%02d %02d:%02d:%02d\n",
           year, month, day, hours, minutes, seconds);
}

void write_time(int file) {
    time_t curTime = time(NULL);
    char* time_string = ctime(&curTime);
    printf(time_string);
}

int main() {
    const char *device = "/dev/i2c-1";  // I2C bus for Raspberry Pi 4
    int file;

    // Open the I2C device
    if ((file = open(device, O_RDWR)) < 0) {
        perror("Failed to open the I2C bus");
        return 1;
    }

    // Specify the I2C address of the RTC
    if (ioctl(file, I2C_SLAVE, RTC_ADDRESS) < 0) {
        perror("Failed to connect to the RTC");
        close(file);
        return 1;
    }

    // Read and display the current time
    read_time(file);
    write_time(file);

    // Close the I2C device
    close(file);
    return 0;
}
