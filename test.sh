mkdir root
cd root
echo 'cd root && bash ../root.sh' > ../start.sh
cp ../vm.sh root/
bash ../root.sh
