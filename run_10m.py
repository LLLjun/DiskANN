import os

dataset = "turing"
size_data = 10
stage = "both"


format = "float"

path_dataset = "dataset/" + dataset
path_datasize = path_dataset + "/" + dataset + str(size_data) + "m"
path_base = path_datasize + "/base." + str(size_data) + "m.fbin"
path_gt = path_datasize + "/groundtruth." + str(size_data) + "m.bin"
path_query = path_dataset + "/query.public.10K.fbin"
path_index = "graphindex/" + dataset + str(size_data) + "m"
path_output = "Output/" + dataset + str(size_data) + "m"

if dataset == "turing":
    path_query = path_dataset + "/query100K.fbin"

R = 40
L = 60
B = 0.6
M = 10
T = 40

num_nodes_to_cache = 20000
num_threads = 8
beam_width = 4
K = 10


def main():
    cmd_build  =  "./build/tests/build_disk_index " + \
                format + " l2 " + \
                path_base + " " + \
                path_index + " " + \
                str(R) + " " + str(L) + " " + str(B) + " " + str(M) + " " + str(T) + " 0"

    cmd_search = "./build/tests/search_disk_index " + \
                format + " l2 " + \
                path_index + " " + \
                str(num_nodes_to_cache) + " " + str(num_threads) + " " + str(beam_width) + " " + \
                path_query + " " + path_gt + " " + \
                str(K) + " " + path_output + " " + \
                "10 20 30 40 50 60 70 80 90 100"

    if stage == "build" or "both":
        os.system(cmd_build)
    if stage == "search" or "both":
        os.system(cmd_search)


main()