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

// Convert decimal to BCD
int decimal_to_bcd(int decimal) {
    return ((decimal / 10) << 4) | (decimal % 10);
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
    int year = bcd_to_decimal(buf[6]) + 2000;  // year since 2000

    // Print the current time
    printf("Current time: %04d-%02d-%02d %02d:%02d:%02d\n",
           year, month, day, hours, minutes, seconds);
}

void write_time(int file) {
    time_t curTime = time(NULL);
    struct tm *localTime = localtime(&curTime);

    // Prepare the time data in BCD format
    unsigned char buf[8];
    buf[1] = decimal_to_bcd(localTime->tm_sec);   // Seconds
    buf[2] = decimal_to_bcd(localTime->tm_min);   // Minutes
    buf[3] = decimal_to_bcd(localTime->tm_hour);  // Hours
    buf[4] = 0;                                    // Day of week (not used)
    buf[5] = decimal_to_bcd(localTime->tm_mday);  // Day of month
    buf[6] = decimal_to_bcd(localTime->tm_mon + 1); // Month (tm_mon is 0-11)
    buf[7] = decimal_to_bcd(localTime->tm_year % 100); // Year since 2000

    // Set register pointer to 0x00 (seconds register)
    buf[0] = 0x00; // Start writing from seconds register
    if (write(file, buf, sizeof(buf)) != sizeof(buf)) {
        perror("Failed to write time to the RTC");
        return;
    }

    printf("Current time written to RTC: %04d-%02d-%02d %02d:%02d:%02d\n",
           localTime->tm_year + 1900, localTime->tm_mon + 1, localTime->tm_mday,
           localTime->tm_hour, localTime->tm_min, localTime->tm_sec);
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

    // Write the current time to the RTC
    write_time(file);

    // Read and display the current time
    read_time(file);

    // Close the I2C device
    close(file);
    return 0;
}
