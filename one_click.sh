source ~/.bashrc
cd /mnt/localssd/

git clone git@github.com:dddraxxx/r1v-seg.git
cd r1v-seg
git switch v3

bash setup.sh
bash prepare_data_v2.sh
bash $@
