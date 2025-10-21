if [ ! -d "./root" ]; then
    git clone https://github.com/lavabyte/root
    printf "exit" | bash root/root.sh
    mv vm.sh root/root/
fi
printf "bash vm.sh" | bash root/root.sh
