package LoadCellSubsystemRequirement{
	
    package OverallsystemDefinition{
        import OEMGeneralDefinition::*;
        import ISQ::*;
		import SI::*;
		import ScalarValues::*;
		import Partdefinition::*;
		import PortDefinition::*;
	
        package Partdefinition{
            part def def_OverallSystem:> OEMGeneralDefinition::GeneralPartDefinition::def_OverallSystem{
                attribute Loadcellnumber:Real;
            }
            part def def_LoadCell:> OEMGeneralDefinition::GeneralPartDefinition::def_LoadCell{}
            part def def_MeasuringRing:>OEMGeneralDefinition::GeneralPartDefinition::def_MeasuringRing{}
            part def def_EnergySystem:>OEMGeneralDefinition::GeneralPartDefinition::def_EnergySystem;
        }
        package PortDefinition{
            port def def_MeasuringInfoPort_v1:> OEMGeneralDefinition::GeneralPortDefinition::def_port_MeasuringInfo;
            port def def_EnergyPort_v1:> OEMGeneralDefinition::GeneralPortDefinition::def_port_Energy ;
            port def def_TemperaturePort_v1:> OEMGeneralDefinition::GeneralPortDefinition::def_port_Temperature;
            port def def_MassPort_v1:> OEMGeneralDefinition::GeneralPortDefinition::def_port_Mass;
		}
        package InterfaceDefinition{
            interface def def_MessDataInterface:> OEMGeneralDefinition::GeneralInterfaceDefinition::def_MessDataInterface;
            interface def def_EnergyInterface:> OEMGeneralDefinition::GeneralInterfaceDefinition::def_EnergyInterface;
            interface def def_TemperatureInterface:> OEMGeneralDefinition::GeneralInterfaceDefinition::def_TemperatureInterface;
	    }
        package ActionDefinition{
            action def def_act_ForceMeasurement:> OEMGeneralDefinition::GeneralActionDefinition::def_act_ForceMeasurement;
            
        }
        package ItemDefinition{
            item def def_MeasuringObject{
				attribute ObjectMass:>ISQ::mass;
			}
        }
        package RequirementDefinition{
            requirement def def_TemperatureRequirement:> OEMGeneralDefinition::GeneralRequirementDefinition::def_TemperatureRequirement;
            requirement def def_AccuracyRequirement:> OEMGeneralDefinition::GeneralRequirementDefinition::def_AccuracyRequirement;
            requirement def def_MeasurementRequirement:> OEMGeneralDefinition::GeneralRequirementDefinition::def_MeasurementRequirement;
        }
    }
    package OverallSystemModel{
        import OverallsystemDefinition::*;
        package PartsTree{
            part OverallSystem_v1 : Partdefinition::def_OverallSystem{
                attribute num redefines Partdefinition::def_OverallSystem::Loadcellnumber=3;
                attribute Time redefines Partdefinition::def_OverallSystem::time; 
                part loadcell:Partdefinition::def_LoadCell{
                    attribute loadcellTmax redefines Partdefinition::def_LoadCell::Tmax;
                    attribute loadcellTmin redefines Partdefinition::def_LoadCell::Tmin;
                    attribute loadcellmaintenanceTime redefines Partdefinition::def_LoadCell::maintenanceTime; 
                    attribute loadcellvoltage redefines Partdefinition::def_LoadCell::voltage=12[V];
                    attribute loadcellCapacity redefines Partdefinition::def_LoadCell::maximumCapacity;
                    attribute loadcellAccuracyClass redefines Partdefinition::def_LoadCell::AccuracyClass;
                    port port_messinfo:def_MeasuringInfoPort_v1;
                    port port_temperature_lc:def_TemperaturePort_v1;
                    }
                part MeasuringRing:Partdefinition::def_MeasuringRing;
                part EnergySystem:Partdefinition::def_EnergySystem{
                    port port_outputenergy:~def_EnergyPort_v1;
                }
                interface energyInterface:InterfaceDefinition::def_EnergyInterface
                    connect EnergySystem.port_outputenergy to loadcell.port_InputEnergy;
                bind loadcell.port_messinfo = OverallSystem_v1.port_MeasuringInfo;
                bind loadcell.port_temperature_lc= OverallSystem_v1.port_Temperature;
                satisfy requirements::TemperatureRequirement by OverallSystem_v1{
                    requirement TemperatureRequirement :>>requirements::TemperatureRequirement{
                        attribute redefines temperatureActual = OverallSystem_v1.port_Temperature.Roomtemperature;
                        attribute redefines maximumWorkingTemperature = OverallSystem_v1.loadcell.loadcellTmax;
                        attribute redefines minimumWorkingTemperature = OverallSystem_v1.loadcell.loadcellTmin;
                        }
                }
                satisfy requirements::MeasurementRequirement by OverallSystem_v1{
                    requirement MeasurementRequirement :>> requirements::MeasurementRequirement{
                        attribute redefines loadallowed = OverallSystem_v1.num * OverallSystem_v1.loadcell.loadcellCapacity;
                    }
                }
                satisfy requirements::AccuracyRequirement by OverallSystem_v1{
                    requirement AccuracyRequirement :>> requirements::AccuracyRequirement{
                        attribute redefines AccuracyClassActual = OverallSystem_v1.loadcell.loadcellAccuracyClass;
                    }
                }
            }
        }
        package ActionTree{
            action act_ForceMeasurement:ActionDefinition::def_act_ForceMeasurement{
            }
        }
        package requirements {
		
            requirement TemperatureRequirement: RequirementDefinition::def_TemperatureRequirement{
                    doc /* The load cell should run normally in certain temperature range.*/
                    attribute redefines maximumTemperature = 60['°C'];
                    attribute redefines minimumTemperature =-10['°C'];
                }
            requirement MeasurementRequirement: RequirementDefinition::def_MeasurementRequirement {
                doc /* The load cell should provide a certain static measurement range in the direction of gravity and a certain dynamic measurement range. */
                
                attribute redefines staticLoadRequired =350[N] ;
                attribute redefines dynamicLoadRequired =10[N];
                attribute loadallowed redefines LoadAllowed;
                require constraint {loadallowed>=staticLoadRequired+dynamicLoadRequired}
                }
            requirement AccuracyRequirement:RequirementDefinition::def_AccuracyRequirement {
                doc /* The measuring system should provide a certain static measurement Accuracy. */
                attribute redefines AccuracyClass="C3";
                
                require constraint {AccuracyClass==AccuracyClassActual}
                }
        }
    }
}