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
            /*output port which send the result of measuring */
            port port_Mass:def_port_Mass;
            attribute Loadcellnumber:Real;
        }
        part def def_LoadCell{
            /*subsystem that require the collaboration from supplier, which can measure the vertical force*/
            attribute maximumCapacity:>ISQ::mass;
            attribute voltage:>ISQ::voltage;
            port port_Inputmass:def_port_Mass;
            /*input port for load cell to measure the object*/
            port port_InputEnergy:def_port_Energy;
            /*input port (for load cell) which get the electical power*/
            port port_messinfo:GeneralPortDefinition::def_port_MeasuringInfo;
            /*output port which send the result of measuring */
		}
        part def def_EnergySystem{
            /*subsystem 2, energy system which can supply power for all system element. In this example only for load cell*/
            port port_OutputEnergy:~def_port_Energy;
            /*conjugated input port which supply the electical power*/
            /*"~" means conjugated port*/
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
}

package LoadCellSubsystemRequirement{
	/*package from OEM which should share/send to supplier as the requirement for loadcell*/

    package OverallSystemModel{
        public import OEMGeneralDefinition::*;
        package PartsTree{
            part OverallSystem_v1 : GeneralPartDefinition::def_OverallSystem{
                /*use (symbol':') the definition to define the overall system, which will heritate all the properties of definitions*/
                attribute num redefines GeneralPartDefinition::def_OverallSystem::Loadcellnumber=3;
                /*redefine the attribute to assign the value*/
                part loadcell:GeneralPartDefinition::def_LoadCell{
                /*define the hierarchie, loadcell is inside of overall system, which means loadcell is the subsystem of overall system */
                    attribute loadcellvoltage redefines GeneralPartDefinition::def_LoadCell::voltage=12[V];
                    attribute loadcellCapacity redefines GeneralPartDefinition::def_LoadCell::maximumCapacity;
                    }
                part EnergySystem:GeneralPartDefinition::def_EnergySystem{}
                interface energyInterface:GeneralInterfaceDefinition::def_EnergyInterface
                    connect EnergySystem.port_OutputEnergy to loadcell.port_InputEnergy;
                    /*port from energy system is connected to corresponding port from load cell (output-->input)*/
                bind loadcell.port_messinfo = OverallSystem_v1.port_MeasuringInfo;
                /*bind means output-->output*/
            }
        }
    }
}


