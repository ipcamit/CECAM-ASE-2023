# See all available verification checks
kimitems search -t vc ".*"


# Installing is as simple as
kimitems install PermutationSymmetry__VC_903502816694_002

# kimitems make these installation a breeze, otherwise will include manual copying

# set env variable for Libtorch workaround
source /home/openkim/MACH2023/ASEExample/source.sh

# Now to run the test against your model
pipeline-run-pair -v  PermutationSymmetry__VC_903502816694_002 SF__MO_000000000000_000
