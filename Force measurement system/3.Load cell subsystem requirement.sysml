package LoadCellSubsystemRequirement{
	
    package OverallsystemDefinition{
        import OEMGeneralDefinition::*;
        import ISQ::*;
		import SI::*;
		import ScalarValues::*;
		import Partdefinition::*;
		import PortDefinition::*;
	
        package Partdefinition{
            part def OverallSystem:> OEMGeneralDefinition::GeneralPartDefinition::OverallSystem{
                attribute Loadcellnumber:Real;
            }
            part def LoadCell:> OEMGeneralDefinition::GeneralPartDefinition::LoadCell{}
            part def MeasuringRing:>OEMGeneralDefinition::GeneralPartDefinition::MeasuringRing{}
            part def EnergySystem:>OEMGeneralDefinition::GeneralPartDefinition::EnergySystem;
        }
        package PortDefinition{
            port def MeasuringInfoPort_v1:> OEMGeneralDefinition::GeneralPortDefinition::MeasuringInfoPort;
            port def EnergyPort_v1:> OEMGeneralDefinition::GeneralPortDefinition::EnergyPort ;
            port def TemperaturePort_v1:> OEMGeneralDefinition::GeneralPortDefinition::TemperaturePort;
            port def MassPort_v1:> OEMGeneralDefinition::GeneralPortDefinition::MassPort;
		}
        package InterfaceDefinition{
            interface def MessDataInterface:> OEMGeneralDefinition::GeneralInterfaceDefinition::MessDataInterface;
            interface def EnergyInterface:> OEMGeneralDefinition::GeneralInterfaceDefinition::EnergyInterface;
            interface def TemperatureInterface:> OEMGeneralDefinition::GeneralInterfaceDefinition::TemperatureInterface;
	    }
        package ActionDefinition{
            action def ForceMeasurement:> OEMGeneralDefinition::GeneralActionDefinition::ForceMeasurement;
            
        }
        package ItemDefinition{
            item def MeasuringObject{
				attribute ObjectMass:>ISQ::mass;
			}
        }
        package RequirementDefinition{
            requirement def Temperature:> OEMGeneralDefinition::GeneralRequirementDefinition::TemperatureRequirement;
            requirement def AccuracyRequirement:> OEMGeneralDefinition::GeneralRequirementDefinition::AccuracyRequirement;
            requirement def MeasurementRequirement:> OEMGeneralDefinition::GeneralRequirementDefinition::MeasurementRequirement;
        }
    }
    package OverallSystemModel{
        import OverallsystemDefinition::*;
        package PartsTree{
            part OverallSystem_v1 : Partdefinition::OverallSystem{
                attribute num redefines Partdefinition::OverallSystem::Loadcellnumber=3;
                attribute  redefines Partdefinition::OverallSystem::maintenanceTime=3600[h]; 
                perform ActionTree::ForceMeasurement redefines ForceMeasurement;
                part loadcell:Partdefinition::LoadCell{
                    attribute loadcellTmax redefines Partdefinition::LoadCell::Tmax;
                    attribute loadcellTmin redefines Partdefinition::LoadCell::Tmin;
                    attribute  redefines Partdefinition::LoadCell::maintenanceTime; 
                    attribute  redefines Partdefinition::LoadCell::voltage=12[V];
                    attribute  loadcellCapacity redefines Partdefinition::LoadCell::maximumCapacity;
                    attribute loadcellAccuracyClass redefines Partdefinition::LoadCell::AccuracyClass;
		        port messinfoPort:MeasuringInfoPort_v1;
                port temperature_lc_Port:TemperaturePort_v1;
                    }
                part MeasuringRing:Partdefinition::MeasuringRing;
                part EnergySystem:Partdefinition::EnergySystem{
                    port outputenergyPort:~EnergyPort_v1;
                }
                interface energyInterface:InterfaceDefinition::EnergyInterface
                    connect EnergySystem.outputenergyPort to loadcell.InputEnergyPort;
                bind loadcell.messinfoPort = OverallSystem_v1.MessResultPort;
                bind loadcell.temperature_lc_Port= OverallSystem_v1.temperaturePort;
                satisfy requirements::TemperatureRequirement by OverallSystem_v1{
                    requirement TemperatureRequirement :>>requirements::TemperatureRequirement{
                        attribute redefines temperatureActual = OverallSystem_v1.temperaturePort.Roomtemperature;
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
            action ForceMeasurement:ActionDefinition::ForceMeasurement{
            }
        }
        package requirements {
		
            requirement TemperatureRequirement: RequirementDefinition::Temperature{
                    doc /* The load cell should run normally in certain temperature range.*/
                    attribute redefines maximumTemperature = 60['°C'];
                    attribute redefines minimumTemperature =-10['°C'];
                }
            requirement MeasurementRequirement: RequirementDefinition::MeasurementRequirement {
                doc /* The load cell should provide a certain static measurement range in the direction of gravity and a certain dynamic measurement range. */
                
                attribute redefines staticLoadRequired =350[N] ;
                attribute redefines dynamicLoadRequired =10[N];
                attribute loadallowed redefines LoadAllowed;
                require constraint {loadallowed>=staticLoadRequired+dynamicLoadRequired}
                }
            requirement AccuracyRequirement:RequirementDefinition::AccuracyRequirement {
                doc /* The measuring system should provide a certain static measurement Accuracy. */
                attribute redefines AccuracyClass="C3";
                
                require constraint {AccuracyClass==AccuracyClassActual}
                }
        }
    }
}