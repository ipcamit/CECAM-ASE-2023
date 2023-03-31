pip install torch==1.13.1+cpu torchvision==0.14.1+cpu torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cpu
pip install torch_geometric torch_scatter torch_sparse torch_cluster -f https://data.pyg.org/whl/torch-1.13.0+cpu.html

# KLIFF dependencies
pip install ase markupsafe==2.0.1 edn_format==0.7.5 kim-edn==1.3.1 kim-property==2.4.0 kim-query==3.0.0 simplejson==3.17.2 matplotlib==3.3.4 pymongo==3.11.3 montydb==2.1.1
#  Jinja2==2.11.3 ? 
pip install kimpy git+https://github.com/colabfit/colabfit-tools@aa2d1e3b160275cdb7d8734afdbbb4a570a92a94#egg=colabfit_tools
#
