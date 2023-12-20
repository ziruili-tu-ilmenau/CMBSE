package LoadCellSolution{
    package Definition{
    	import Tier1GeneralDefinition::*;
        import OEMGeneralDefinition::*;
		import Partdefinition::*;
		import PortDefinition::*;
        import InterfaceDefinition::*;
        import ActionDefinition::*;
        import SignalDefinition::*;
        import StateDefinition::*;
        import ItemDefinition::*;
        package Partdefinition{
            part def OverallSystem:>OEMGeneralDefinition::GeneralPartDefinition::OverallSystem{
                attribute Loadcellnumber:Real;
            }
            part def LoadCell:>Tier1GeneralDefinition::'Load Cell Part Definition'::loadcell;
            part def StrainGauge:>Tier1GeneralDefinition::'Load Cell Part Definition'::StrainGauge;
            part def MeasuringRing:>OEMGeneralDefinition::GeneralPartDefinition::MeasuringRing;
            part def EnergySystem:>OEMGeneralDefinition::GeneralPartDefinition::EnergySystem;
        }
        package PortDefinition{
            port def measuringInfoPort:>Tier1GeneralDefinition::'Load Cell Port Definition'::MeasuringInfoPort;
            port def EnergyPort:>Tier1GeneralDefinition::'Load Cell Port Definition'::PowerPort;
        }
        package InterfaceDefinition{
            interface def MessDataInterface:>OEMGeneralDefinition::GeneralInterfaceDefinition::MessDataInterface;
            interface def EnergyInterface:>OEMGeneralDefinition::GeneralInterfaceDefinition::EnergyInterface;
            interface def TemperatureInterface:>OEMGeneralDefinition::GeneralInterfaceDefinition::TemperatureInterface;
	    }
        package ActionDefinition{
            action def ForceMeasurement:>OEMGeneralDefinition::GeneralActionDefinition::ForceMeasurement;
            action def ResultConvert{
            	millivolt :> scalarQuantities = ISQ::voltage*1000;
                in MessData:> millivolt;
                out messresult:>ISQ::mass;
            }
            action def ForceToVoltage{
                in item measuringObject:'Load Cell Item Definition'::MeasuringObject;
                millivolt :> scalarQuantities = ISQ::voltage*1000;
                out MessData:> millivolt;
            }
            action def ForceMeasurement_loadcell:>Tier1GeneralDefinition::'Load Cell Action Definition'::ForceMeasurement_loadcell;
        }
        package SignalDefinition{
            attribute def SystemOffSignal:>Tier1GeneralDefinition::'Load Cell Signal Definition'::SystemOffSignal;
            attribute def SystemOnSignal:>Tier1GeneralDefinition::'Load Cell Signal Definition'::SystemOnSignal;
            attribute def measureCmd:>Tier1GeneralDefinition::'Load Cell Signal Definition'::measureCmd;
        }
        package StateDefinition{
            state def Loadcellstate:>Tier1GeneralDefinition::'Load Cell State Definition'::Loadcellstate;
        }
        package ItemDefinition{
            item def MeasuringObject:>Tier1GeneralDefinition::'Load Cell Item Definition'::MeasuringObject;
        }
        package RequirementDefinition{
            requirement def TemperatureRequirement:> OEMGeneralDefinition::GeneralRequirementDefinition::TemperatureRequirement;
        	requirement def AccuracyRequirement:> OEMGeneralDefinition::GeneralRequirementDefinition::AccuracyRequirement;
            requirement def MeasurementRequirement:> OEMGeneralDefinition::GeneralRequirementDefinition::MeasurementRequirement;
        }
    }
    package LoadCellSolutionModel{
        import Definition::*;
        package PartsTree{
            part OverallSystem_v1 : Partdefinition::OverallSystem{
                attribute num redefines Partdefinition::OverallSystem::Loadcellnumber=3;
                attribute  redefines Partdefinition::OverallSystem::maintenanceTime=3600[h]; 
                port messResultPort:~measuringInfoPort;
                perform ActionTree::ForceMeasurement redefines ForceMeasurement;
                part loadcell_v1:LoadCell{
                    attribute loadcellMass redefines mass=2[kg];
                    attribute loadcellTmax redefines Tmax=60['°C'];
                    attribute loadcellTmin redefines Tmin=-10['°C'];
                    attribute loadcellTamax redefines Tamax=65['°C'];
                    attribute loadcellTamin redefines Tamin=-15['°C'];
                    attribute  redefines maintenanceTime=4000[h]; 
                    attribute  redefines inputvoltage=12[V];
                    attribute  loadcellCapacity redefines maximumCapacity=40[kg];
                    attribute loadcellAccuracyClass redefines AccuracyClass="C3";	
                    port messinfoPort:measuringInfoPort;
                    port  energyPort : EnergyPort;
                    part 'Strain Gauge':'Load Cell Part Definition'::StrainGauge{
			 			attribute :>>Material="Aluminium";
			 		}
                }
                part MeasuringRing:Partdefinition::MeasuringRing;
                part EnergySystem:Partdefinition::EnergySystem{
                    port outputenergyPort:~EnergyPort;
                }
                interface energyInterface:InterfaceDefinition::EnergyInterface
                    connect EnergySystem.outputenergyPort to loadcell_v1.energyPort;
                interface TemperatureInterface:InterfaceDefinition::TemperatureInterface
                    connect OverallSystem_v1.temperaturePort to loadcell_v1.temperaturePort;
                bind loadcell_v1.messinfoPort = OverallSystem_v1.messResultPort;
                satisfy requirements::TemperatureRequirement by OverallSystem_v1{
                    requirement TemperatureRequirement :>>requirements::TemperatureRequirement{
                        attribute redefines temperatureActual = OverallSystem_v1.temperaturePort.Roomtemperature;
                        attribute redefines maximumWorkingTemperature = OverallSystem_v1.loadcell_v1.loadcellTmax;
                        attribute redefines minimumWorkingTemperature = OverallSystem_v1.loadcell_v1.loadcellTmin;
                        }
                }
                satisfy requirements::MeasurementRequirement by OverallSystem_v1{
                    requirement MeasurementRequirement :>> requirements::MeasurementRequirement{
                        attribute redefines LoadAllowed = OverallSystem_v1.num * OverallSystem_v1.loadcell_v1.loadcellCapacity;
                    }
                }
                satisfy requirements::AccuracyRequirement by OverallSystem_v1{
                    requirement AccuracyRequirement :>> requirements::AccuracyRequirement{
                        attribute redefines AccuracyClassActual = OverallSystem_v1.loadcell_v1.loadcellAccuracyClass;
                    }
                }
            }
        }
        package ActionTree{
            action ForceMeasurement:ActionDefinition::ForceMeasurement{
                action forceMeasurement_loadcell:ActionDefinition::ForceMeasurement_loadcell{
                    action ResultConvert:ActionDefinition::ResultConvert;
                    action ForceToVoltage:ActionDefinition::ForceToVoltage;
                    flow ForceToVoltage.MessData to ResultConvert.MessData;
                    bind ResultConvert.messresult = ForceMeasurement.messresult;
                }
            }
        }
        package requirements{
            requirement TemperatureRequirement: RequirementDefinition::TemperatureRequirement{
            
            	doc /* The measuring system should run normally in certain temperature range.*/
		        attribute redefines maximumTemperature =60['°C'];
		        attribute redefines minimumTemperature=-10['°C'];
		        attribute redefines minimumWorkingTemperature;
		        attribute redefines maximumWorkingTemperature;
		        attribute redefines temperatureActual;
		        
		        require constraint {maximumTemperature>=temperatureActual}
		        require constraint {temperatureActual>=minimumTemperature}
		        require constraint {maximumWorkingTemperature>maximumTemperature}
		        require constraint {minimumTemperature>minimumWorkingTemperature}
        	}
        	
        	
            requirement MeasurementRequirement: RequirementDefinition::MeasurementRequirement {
                doc /* The measuring system should provide a certain static measurement range in the direction of gravity and a certain dynamic measurement range. */
                
                attribute redefines staticLoadRequired =35[kg] ;
                attribute redefines dynamicLoadRequired =1[kg];
                attribute redefines LoadAllowed;
                require constraint {LoadAllowed>=staticLoadRequired+dynamicLoadRequired}
            
                }
            requirement  AccuracyRequirement:'Requirement Definition'::AccuracyRequirement{
                doc /* The load cell should provide a certain static measurement Accuracy. */
                attribute redefines AccuracyClass="C3";
                attribute redefines AccuracyClassActual:String;
                require constraint {AccuracyClass==AccuracyClassActual}
            }
        }
    }
}