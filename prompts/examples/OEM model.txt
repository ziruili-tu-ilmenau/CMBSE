package OEMRequirements{
package OEMGeneralDefinition{
	public import ISQ::*;
	public import SI::*;
	public import ScalarValues::*;
    package GeneralPartDefinition{
    	public import GeneralPortDefinition::*;
        part def def_OverallSystem{
            port port_MeasuringInfo:def_port_MeasuringInfo;
            port port_Mass:def_port_Mass;
            attribute Loadcellnumber:Real;
        }
        part def def_LoadCell{
            attribute maximumCapacity:>ISQ::mass;
            attribute voltage:>ISQ::voltage;
            port port_Inputmass:def_port_Mass;
            port port_InputEnergy:def_port_Energy;
            port port_messinfo:GeneralPortDefinition::def_port_MeasuringInfo;
		}
        part def def_EnergySystem{
            port port_OutputEnergy:~def_port_Energy;
	    }
    }
    package GeneralPortDefinition{
        port def def_port_MeasuringInfo { 
            out MessData :> ISQ::mass;
                }
        port def def_port_Energy { 
            in inputVoltage :> ISQ::voltage;
                }
        port def def_port_Mass { 
		    in inputMass :> ISQ::mass;
		}	
	}
    package GeneralInterfaceDefinition{
    	public import GeneralPortDefinition::*;
        interface def def_MessDataInterface{
            end p1:def_port_MeasuringInfo;
            end p2:~def_port_MeasuringInfo;
            flow p1.MessData to p2.MessData;
        }
        interface def def_EnergyInterface{
            end p1:def_port_Energy;
            end p2:~def_port_Energy;
            flow p2.inputVoltage to p1.inputVoltage;
        }
    }
}

package LoadCellSubsystemRequirement{
    package OverallSystemModel{
        public import OEMGeneralDefinition::*;
        package PartsTree{
            part OverallSystem_v1 : GeneralPartDefinition::def_OverallSystem{
                attribute num redefines GeneralPartDefinition::def_OverallSystem::Loadcellnumber=3;
                part loadcell:GeneralPartDefinition::def_LoadCell{
                    attribute loadcellvoltage redefines GeneralPartDefinition::def_LoadCell::voltage=12[V];
                    attribute loadcellCapacity redefines GeneralPartDefinition::def_LoadCell::maximumCapacity;
                    }
                part EnergySystem:GeneralPartDefinition::def_EnergySystem{}
                interface energyInterface:GeneralInterfaceDefinition::def_EnergyInterface
                    connect EnergySystem.port_OutputEnergy to loadcell.port_InputEnergy;
                bind loadcell.port_messinfo = OverallSystem_v1.port_MeasuringInfo;
            }
        }
    }
}
}