qd_launch2(){
    # --interactive \
    set_runai_eks04
    job_name=${1:-ev2}
    script_name=${2:-"scripts/run_eval_dist_base_long.sh"}
    user=yitianz
    runai delete job $job_name; runai submit \
    --large-shm \
    -e NCCL_SOCKET_IFNAME=eth0 -e FI_PROVIDER=efa -e FI_EFA_USE_DEVICE_RDMA=1 \
    -i docker-matrix-experiments-snapshot.dr-uw2.adobeitc.com/runai/clio-base-beta:0.21 \
    -p clineto-over-quota \
    --backoff-limit 15 \
    --extended-resource vpc.amazonaws.com/efa=4 \
    --extended-resource hugepages-2Mi=2048Mi \
    -g 8 \
    --node-pools a100-80gb-1 \
    --name $job_name \
    --command -- bash -c "source /sensei-fs/users/$user/qd/setup.sh; entry_setup; curl -sL https://raw.githubusercontent.com/dddraxxx/running_scripts/refs/heads/main/one_click.sh | bash -s $script_name | tee /sensei-fs/users/$user/qd/$job_name.log"
}
runai config project clineto-over-quota
qd_launch2 low run_grpo_rec_low.sh
qd_launch2 lower run_grpo_rec_low2.sh
qd_launch2 seg3 training_scripts/v1_longref7b_contiou.sh
