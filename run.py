import os

dataset = "deep"
size_data = 1
stage = "search"


format = "float"

path_dataset = "dataset/" + dataset
path_datasize = path_dataset + "/" + dataset + str(size_data) + "m"
path_base = path_datasize + "/base." + str(size_data) + "m.fbin"
path_gt = path_datasize + "/groundtruth." + str(size_data) + "m.bin"
path_query = path_dataset + "/query.public.10K.fbin"
path_index = "graphindex/" + dataset + str(size_data) + "m"
path_output = "Output/" + dataset + str(size_data) + "m"

R = 40
L = 60
B = 0.06
M = 1
T = 40

num_nodes_to_cache = 2000
num_threads = 40
beam_width = 0
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

    if stage == "build":
        os.system(cmd_build)
    if stage == "search":
        os.system(cmd_search)


main()