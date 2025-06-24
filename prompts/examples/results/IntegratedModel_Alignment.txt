package IntegratedModel_Alignment {
  public import OEM::*;
  private import Supplier::*;
  public import AllocationExtension::*;

  alias def_LoadCell for loadcell_def;
  #RequireModification allocation def_LoadCell to loadcell_v1;
  alias def_EnergySystem for EnergySystem_def;
  #RequireModification allocation def_EnergySystem to EnergySystem;
  alias def_port_MeasuringInfo for port_MeasuringInfo_def;
  alias def_port_Mass for port_Mass_def;
  alias def_MessDataInterface for MessDataInterface_def;
  #RequireModification allocation loadcell to loadcell_def;
  alias loadcell for loadcell_v1;
  #RequireModification allocation EnergySystem to EnergySystem_def;
  alias EnergySystem for EnergySystem;
  #FullyMatched allocation OverallSystem_v1::EnergySystem to MeasuringSystem_v1::EnergySystem;
  #RequireComplement allocation OverallSystem_v1::loadcell to MeasuringSystem_v1::loadcell_v1;
}