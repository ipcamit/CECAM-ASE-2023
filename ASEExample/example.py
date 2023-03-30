# Example ASE Script

# 1. Import the ASE package, and ASE KIM calculator
import ase.io
from ase.calculators.kim import KIM

# 2. Read the structure from a file
XYZ_FILE_PATH = "test_si.xyz"
atoms = ase.io.read(XYZ_FILE_PATH, format="extxyz")

# 3. Select the model and create the calculator
model_name = "TorchMLModel2_Desc"
calc = KIM(model_name, options={"ase_neigh": False})
# calc = KIM(model_name, options={"ase_neigh": False, "neigh_skin_ratio": 0.0})

# 4. Attach the calculator to the atoms object
atoms.set_calculator(calc)

# 5. Run the calculation
print(f"Forces from ASE:\n{atoms.get_forces()}")
print(f"Energy from ASE = {atoms.get_potential_energy()} eV")

