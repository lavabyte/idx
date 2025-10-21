cd root
if [ ! -d "./root" ]; then
    git clone https://github.com/lavabyte/root
    cd root
    printf "exit" | bash root.sh
    mv ../vm.sh root/
fi
printf "bash vm.sh" | bash root/root.sh
