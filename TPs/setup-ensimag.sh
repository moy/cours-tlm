#! /bin/echo Non, il ne faut pas executer ce fichier, mais faire: source

export SYSTEMCROOT=/matieres/5MMMTSP/tlm/systemc-2.3.1/

# Chaine de cross-compilation MicroBlaze, pour le TP3
xilinx=/matieres/5MMMTSP/tlm/microblaze/setup.sh
if [ -f "$xilinx" ]; then
    source "$xilinx"
fi
