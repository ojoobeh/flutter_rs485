#include <jni.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <android/log.h>

#define LOG_TAG "SerialPort"
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

static speed_t getBaudRate(int baudrate) {
    switch (baudrate) {
        case 0: return B0;
        case 50: return B50;
        case 75: return B75;
        case 110: return B110;
        case 134: return B134;
        case 150: return B150;
        case 200: return B200;
        case 300: return B300;
        case 600: return B600;
        case 1200: return B1200;
        case 1800: return B1800;
        case 2400: return B2400;
        case 4800: return B4800;
        case 9600: return B9600;
        case 19200: return B19200;
        case 38400: return B38400;
        case 57600: return B57600;
        case 115200: return B115200;
        case 230400: return B230400;
        case 460800: return B460800;
        case 500000: return B500000;
        case 576000: return B576000;
        case 921600: return B921600;
        case 1000000: return B1000000;
        case 1152000: return B1152000;
        case 1500000: return B1500000;
        case 2000000: return B2000000;
        case 2500000: return B2500000;
        case 3000000: return B3000000;
        case 3500000: return B3500000;
        case 4000000: return B4000000;
        default: return -1;
    }
}

extern "C" JNIEXPORT jobject JNICALL
Java_com_example_untitled4_SerialPort_open(JNIEnv *env, jobject thiz, jstring path, jint baudrate, jint flags) {
    const char *path_utf = env->GetStringUTFChars(path, nullptr);

    speed_t speed = getBaudRate(baudrate);
    if (speed == -1) {
        LOGE("Invalid baud rate: %d", baudrate);
        env->ReleaseStringUTFChars(path, path_utf);
        return nullptr;
    }

    int fd = open(path_utf, O_RDWR | O_NOCTTY | O_NONBLOCK);
    env->ReleaseStringUTFChars(path, path_utf);

    if (fd == -1) {
        LOGE("Cannot open port");
        return nullptr;
    }

    struct termios cfg;
    if (tcgetattr(fd, &cfg)) {
        LOGE("tcgetattr() failed");
        close(fd);
        return nullptr;
    }

    cfmakeraw(&cfg);
    cfsetispeed(&cfg, speed);
    cfsetospeed(&cfg, speed);

    if (tcsetattr(fd, TCSANOW, &cfg)) {
        LOGE("tcsetattr() failed");
        close(fd);
        return nullptr;
    }

    jclass cFileDescriptor = env->FindClass("java/io/FileDescriptor");
    jmethodID iFileDescriptor = env->GetMethodID(cFileDescriptor, "<init>", "()V");
    jfieldID descriptorID = env->GetFieldID(cFileDescriptor, "descriptor", "I");

    jobject mFileDescriptor = env->NewObject(cFileDescriptor, iFileDescriptor);
    env->SetIntField(mFileDescriptor, descriptorID, (jint) fd);

    return mFileDescriptor;
}

extern "C" JNIEXPORT void JNICALL
Java_com_example_untitled4_SerialPort_close(JNIEnv *env, jobject thiz, jobject fd) {
jclass cFileDescriptor = env->FindClass("java/io/FileDescriptor");
jfieldID descriptorID = env->GetFieldID(cFileDescriptor, "descriptor", "I");
jint descriptor = env->GetIntField(fd, descriptorID);
close(descriptor);
}