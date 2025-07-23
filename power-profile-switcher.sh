#!/bin/bash

# Prompt for sudo password only once
echo "Requesting sudo permissions for the script..."
sudo -v  # Prompt for password at the start of the script

# Function to check for cpupower and install it if missing
check_cpupower() {
    if ! command -v cpupower >/dev/null 2>&1; then
        echo -e "\n\033[1;31m[!] 'cpupower' is not installed.\033[0m"
        read -p "Would you like to install cpupower now? (Y/n): " install_choice
        if [[ "$install_choice" == [Yy] || -z "$install_choice" ]]; then
            echo "Installing cpupower..."
            sudo pacman -S --noconfirm cpupower
            if ! command -v cpupower >/dev/null 2>&1; then
                echo "Installation failed. Exiting."
                exit 1
            fi
        else
            echo "cpupower is required to run this script. Exiting."
            exit 1
        fi
    fi
}

# Function to set GPU power profile by number (using echo <NUM> for profile)
set_gpu_profile() {
    local profile_num=$1
    echo "Setting GPU power profile to profile $profile_num..."
    echo "$profile_num" | sudo tee /sys/class/drm/card0/device/pp_power_profile_mode > /dev/null
}

# Function to set CPU frequency using cpupower
set_cpu_frequency() {
    local freq=$1
    echo "Setting CPU frequency to $freq..."
    sudo cpupower frequency-set -g "$freq" > /dev/null 2>&1
}

# Main menu for selecting GPU and CPU profiles
main_menu() {
    local choice=$1

    if [ -z "$choice" ]; then
        echo "Select GPU and CPU Settings:"
        echo "0) Power Saving (GPU POWER_SAVING and CPU powersave)"
        echo "1) Gaming (GPU 3D_FULL_SCREEN and CPU performance)"
        echo "2) VR (GPU VR and CPU performance)"
        echo "3) Default (Reset to BOOTUP_DEFAULT and CPU powersave)"
        echo "4) Custom (Choose GPU Profile and CPU Frequency)"
        read -p "Enter your choice (0-4): " choice
    fi

    case $choice in
        0)
            echo "Switching to Power Saving (GPU POWER_SAVING and CPU powersave)..."
            set_gpu_profile 2
            set_cpu_frequency "powersave"
            ;;
        1)
            echo "Switching to Gaming (GPU 3D_FULL_SCREEN and CPU performance)..."
            set_gpu_profile 1
            set_cpu_frequency "performance"
            ;;
        2)
            echo "Switching to VR (GPU VR and CPU performance)..."
            set_gpu_profile 4
            set_cpu_frequency "performance"
            ;;
        3)
            echo "Switching to Default (BOOTUP_DEFAULT and CPU powersave)..."
            set_gpu_profile 0
            set_cpu_frequency "powersave"
            ;;
        4)
            custom_menu
            ;;
        *)
            echo "Invalid choice. Please select between 0 and 4."
            ;;
    esac
}

# Custom menu for choosing GPU profile and CPU frequency
custom_menu() {
    echo "Custom GPU and CPU Settings:"
    echo "Select GPU Profile:"
    echo "0) POWER_SAVING"
    echo "1) 3D_FULL_SCREEN"
    echo "2) VR"
    echo "3) BOOTUP_DEFAULT"
    echo "4) COMPUTE"
    echo "5) VIDEO"
    read -p "Enter GPU profile (0-5): " gpu_choice

    echo "Select CPU Frequency:"
    echo "0) powersave"
    echo "1) performance"
    read -p "Enter CPU governor (0-1): " cpu_choice

    case $gpu_choice in
        0) set_gpu_profile 2 ;;  # POWER_SAVING
        1) set_gpu_profile 1 ;;  # 3D_FULL_SCREEN
        2) set_gpu_profile 4 ;;  # VR
        3) set_gpu_profile 0 ;;  # BOOTUP_DEFAULT
        4) set_gpu_profile 5 ;;  # COMPUTE
        5) set_gpu_profile 3 ;;  # VIDEO
        *) echo "Invalid GPU profile choice." ;;
    esac

    case $cpu_choice in
        0) set_cpu_frequency "powersave" ;;
        1) set_cpu_frequency "performance" ;;
        *) echo "Invalid CPU governor choice." ;;
    esac
}

# Run the dependency check
check_cpupower

# Run the main menu
main_menu "$1"
