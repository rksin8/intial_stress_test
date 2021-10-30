[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 5
  ny = 5
  nz = 5
  xmin = 0
  xmax = 1
  ymin = 0
  ymax = 1
  zmin = 0
  zmax = 1
[]

[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./disp_z]
  [../]
[]

[Kernels]
  [./TensorMechanics]
    displacements = 'disp_x disp_y disp_z'
    eigenstrain_names = 'initial_stress'
  [../]
[]


[BCs]
  # back = zmin
  # front = zmax
  # bottom = ymin
  # top = ymax
  # left = xmin
  # right = xmax
  [./xmin_xzero]
    type = DirichletBC
    variable = disp_x
    boundary = 'left'
    value = '0'
  [../]
  [./ymin_yzero]
    type = DirichletBC
    variable = disp_y
    boundary = 'bottom'
    value = '0'
  [../]
  [./zmin_zzero]
    type = DirichletBC
    variable = disp_z
    boundary = 'back'
    value = '0'
  [../]
  [x1]
    type = Pressure
    variable = disp_x
    boundary = 'right'
    component = 0
    factor = 300000
  []
  [y1]
    type = Pressure
    variable = disp_y
    boundary = 'top'
    component = 1
    factor = 200000
  []

  [./zmax_disp]
    type = FunctionDirichletBC
    variable = disp_z
    boundary = 'front'
    function = '-1E-3*t'  # 8mm
  [../]
[]

[AuxVariables]
  [./stress_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_xy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_xz]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_yy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_yz]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_zz]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./mc_int]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./yield_fcn]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./stress_xx]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xx
    index_i = 0
    index_j = 0
  [../]
  [./stress_xy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xy
    index_i = 0
    index_j = 1
  [../]
  [./stress_xz]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xz
    index_i = 0
    index_j = 2
  [../]
  [./stress_yy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yy
    index_i = 1
    index_j = 1
  [../]
  [./stress_yz]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yz
    index_i = 1
    index_j = 2
  [../]
  [./stress_zz]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_zz
    index_i = 2
    index_j = 2
  [../]
  [./mc_int_auxk]
    type = MaterialStdVectorAux
    index = 0
    property = plastic_internal_parameter
    variable = mc_int
  [../]
  [./yield_fcn_auxk]
    type = MaterialStdVectorAux
    index = 0
    property = plastic_yield_function
    variable = yield_fcn
  [../]
[]

[Postprocessors]
  [./s_xx]
    type = PointValue
    point = '0 0 1'
    variable = stress_xx
  [../]
  [./s_xy]
    type = PointValue
    point = '0 0 1'
    variable = stress_xy
  [../]
  [./s_xz]
    type = PointValue
    point = '0 0 1'
    variable = stress_xz
  [../]
  [./s_yy]
    type = PointValue
    point = '0 0 1'
    variable = stress_yy
  [../]
  [./s_yz]
    type = PointValue
    point = '0 0 1'
    variable = stress_yz
  [../]
  [./s_zz]
    type = PointValue
    point = '0 0 1'
    variable = stress_zz
  [../]
  [./mc_int]
    type = PointValue
    point = '0 0 1'
    variable = mc_int
  [../]
  [./f]
    type = PointValue
    point = '0 0 1'
    variable = yield_fcn
  [../]
  [./uzz]
    type = PointValue
    point = '0 0 1'
    variable = disp_z
  [../]
[]

[UserObjects]
  [./mc_coh]
    type = TensorMechanicsHardeningConstant
    value = 70E3
  [../]
  [./mc_phi]
    type = TensorMechanicsHardeningConstant
    value_0 = 0.52  # 30 degree
  [../]
  [./mc_psi]
    type = TensorMechanicsHardeningConstant
    value = 0
  [../]
  [./mc]
    type = TensorMechanicsPlasticMohrCoulomb
    cohesion = mc_coh
    friction_angle = mc_phi
    dilation_angle = mc_psi
    mc_tip_smoother = 0
    mc_edge_smoother = 25
    yield_function_tolerance = 1E-3
    internal_constraint_tolerance = 1E-10
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    block = 0
    poissons_ratio = 0.3
    youngs_modulus = 207e6
  [../]
  [./strain]
    type = ComputeFiniteStrain
    block = 0
    displacements = 'disp_x disp_y disp_z'
    eigenstrain_names = 'initial_stress'
  [../]

 [initial_strain]
   type = ComputeEigenstrainFromInitialStress
   initial_stress = '-3e5 0 0  0 -2e5 0  0 0 -1e5'
   eigenstrain_name = initial_stress
   use_displaced_mesh = false
 []


  [./mc]
    type = ComputeMultiPlasticityStress
    block = 0
    ep_plastic_tolerance = 1E-10
    plastic_models = mc
    max_NR_iterations = 1000
    #debug_fspb = crash
  [../]
[]

[Preconditioning]
  [./andy]
    type = SMP
    full = true
  [../]
[]


[Executioner]
  end_time = 0.8
  dt = 0.05
  solve_type = PJFNK  # cannot use NEWTON because we are using ComputeFiniteStrain, and hence the Jacobian contributions will not be correct, even though ComputeMultiPlasticityStress will compute the correct consistent tangent operator for small strains
  type = Transient

  line_search = 'none'
  nl_rel_tol = 1E-10
  l_tol = 1E-3
  l_max_its = 200
  nl_max_its = 10

  petsc_options_iname = '-pc_type -pc_asm_overlap -sub_pc_type -ksp_type -ksp_gmres_restart'
  petsc_options_value = ' asm      2              lu            gmres     200'
[]



[Outputs]
  file_base = uni_axial1
  exodus = true
  [./csv]
    type = CSV
    [../]
[]
