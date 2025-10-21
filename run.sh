if [ ! -d "./root" ]; then
    git clone https://github.com/lavabyte/root
fi
printf "bash vm.sh" | bash root/root.sh
