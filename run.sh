cd root
if [ ! -d "./root" ]; then
    git clone https://github.com/lavabyte/root >/dev/null 2>/dev/null
    cd root
    printf "exit" | bash root.sh >/dev/null 2>/dev/null
    mv ../vm.sh root/
fi
printf "bash vm.sh" | bash root.sh
