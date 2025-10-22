if [ ! -d "./root" ]; then
    git clone https://github.com/lavabyte/root >/dev/null 2>/dev/null
    cd root
    printf "echo -e '\nbash vm.sh' >> .bashrc && echo -e '\nexit' >> .bashrc && exit" | bash root.sh >/dev/null 2>/dev/null
    mv ../vm.sh root/
fi
bash root.sh
