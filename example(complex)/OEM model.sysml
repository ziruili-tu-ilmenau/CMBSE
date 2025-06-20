package OEMGeneralDefinition{
    /*package that contains the knowledge about system from OEM, is shareable, shouldn't contain IP knowledge*/
	public import ISQ::*;
	private import SI::*;
	private import ScalarValues::*;
    package GeneralPartDefinition{
    	public import GeneralPortDefinition::*;
        part def def_OverallSystem{
            /*overall system that OEM want to develop, which will measure and show the mass of one object*/
            port port_MeasuringInfo:def_port_MeasuringInfo;
            port port_Mass:def_port_Mass;
            attribute Loadcellnumber:Real;
        }
        part def def_LoadCell{
            /*subsystem that require the collaboration from supplier, which can measure the vertical force*/
            attribute maximumCapacity:>ISQ::mass;
            attribute voltage:>ISQ::voltage;
            port port_Inputmass:def_port_Mass;
            port port_InputEnergy:def_port_Energy;
            port port_messinfo:GeneralPortDefinition::def_port_MeasuringInfo;
		}
        part def def_MeasuringRing{
            /*subsystem 2, which is the place where the measuring object can be located*/
        }
        part def def_EnergySystem{
            /*subsystem 3, energy system which can supply power for all system element. In this example only for load cell*/
            port port_OutputEnergy:~def_port_Energy;
	    }
    }
    package GeneralPortDefinition{
        port def def_port_MeasuringInfo { 
            /*output port which send the result of measuring */
            out MessData :> ISQ::mass;
                }
        port def def_port_Energy { 
            /*input port (for load cell) which get the electical power*/
            in inputVoltage :> ISQ::voltage;
                }
        port def def_port_Mass { 
            /*input port for load cell to measure the object*/
		    in inputMass :> ISQ::mass;
		}	
	}
    package GeneralInterfaceDefinition{
    	public import GeneralPortDefinition::*;
        interface def def_MessDataInterface{
            /*processing the measuring information*/
            end p1:def_port_MeasuringInfo;
            end p2:~def_port_MeasuringInfo;
            flow p1.MessData to p2.MessData;
        }
        interface def def_EnergyInterface{
            /*processing the electical energy*/
            end p1:def_port_Energy;
            end p2:~def_port_Energy;
            flow p2.inputVoltage to p1.inputVoltage;
        }
    }
    package GeneralRequirementDefinition{
        requirement def def_MeasurementRequirement {
            doc /* The overall system should provide a certain static measurement range in the direction of gravity and a certain dynamic measurement range. */
            
            attribute staticLoadRequired:>ISQ::force;
            attribute dynamicLoadRequired:>ISQ::force;
            attribute LoadAllowed:>ISQ::force;
            require constraint {LoadAllowed>=staticLoadRequired+dynamicLoadRequired}
            }
    }
}

package LoadCellSubsystemRequirement{
	/*package from OEM which should share/send to supplier as the requirement for loadcell*/

    package OverallSystemModel{
        public import OEMGeneralDefinition::*;
        package PartsTree{
            part OverallSystem_v1 : GeneralPartDefinition::def_OverallSystem{
                attribute num redefines GeneralPartDefinition::def_OverallSystem::Loadcellnumber=3;
                part loadcell:GeneralPartDefinition::def_LoadCell{
                    attribute loadcellvoltage redefines GeneralPartDefinition::def_LoadCell::voltage=12[V];
                    attribute loadcellCapacity redefines GeneralPartDefinition::def_LoadCell::maximumCapacity;
                    }
                part MeasuringRing:GeneralPartDefinition::def_MeasuringRing;
                part EnergySystem:GeneralPartDefinition::def_EnergySystem{
                }
                interface energyInterface:GeneralInterfaceDefinition::def_EnergyInterface
                    connect EnergySystem.port_OutputEnergy to loadcell.port_InputEnergy;
                bind loadcell.port_messinfo = OverallSystem_v1.port_MeasuringInfo;
                satisfy requirements::MeasurementRequirement by OverallSystem_v1{
                    requirement MeasurementRequirement :>> requirements::MeasurementRequirement{
                        attribute redefines loadallowed = OverallSystem_v1.num * OverallSystem_v1.loadcell.loadcellCapacity;
                    }
                }
            }
        }
        package requirements {
            requirement MeasurementRequirement: GeneralRequirementDefinition::def_MeasurementRequirement {
                doc /* The load cell should provide a certain static measurement range in the direction of gravity and a certain dynamic measurement range. */
                
                attribute redefines staticLoadRequired =350[N] ;
                attribute redefines dynamicLoadRequired =10[N];
                attribute loadallowed redefines LoadAllowed;
                require constraint {loadallowed>=staticLoadRequired+dynamicLoadRequired}
                }
        }
    }
}


