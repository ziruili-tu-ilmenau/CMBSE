package ForceMeasurementSystemModel{
	import ForceMeasurementSystem_v1_Definition::*;
	doc
	/*
	 * Example for the OEM developing product: Electronic measuring system
	 */
	package PartsTree{
		part FMS_v1 : FMSPartDefinition::FMS{
	 		attribute num redefines FMSPartDefinition::FMS::Loadcellnumber=3;
	     	attribute  redefines FMSPartDefinition::FMS::maintenanceTime=3600[h]; 
			perform ActionTree::ForceMeasurement redefines ForceMeasurement;
            exhibit state MeasuringSystemState redefines MeasuringSystemState;
			part loadcell:FMSPartDefinition::LoadCell{
				attribute loadcellTmax redefines FMSPartDefinition::LoadCell::Tmax;
				attribute loadcellTmin redefines FMSPartDefinition::LoadCell::Tmin;
		 		attribute  redefines FMSPartDefinition::LoadCell::maintenanceTime; 
		        attribute  redefines FMSPartDefinition::LoadCell::voltage=12[V];
                attribute  loadcellCapacity redefines FMSPartDefinition::LoadCell::maximumCapacity;
                attribute loadcellAccuracyClass redefines FMSPartDefinition::LoadCell::AccuracyClass;
                port temperature_lc_Port:FMSPortDefinition::TemperaturePort_v1;
                }
			part MeasuringRing:FMSPartDefinition::MeasuringRing;
			part EnergySystem:FMSPartDefinition::EnergySystem{
                perform ActionTree::ForceMeasurement.provideEnergy;
            }
            interface energyInterface:FMSInterfaceDefinition::EnergyInterface
                connect EnergySystem.OutputEnergyPort to loadcell.InputEnergyPort;
                bind loadcell.messinfoPort = FMS_v1.MessResultPort;
                bind loadcell.temperature_lc_Port= FMS_v1.temperaturePort;
            satisfy requirements::TemperatureRequirement by FMS_v1{
                requirement TemperatureRequirement :>>requirements::TemperatureRequirement{
                    attribute redefines temperatureActual = FMS_v1.temperaturePort.Roomtemperature;
                    attribute redefines maximumWorkingTemperature = FMS_v1.loadcell.loadcellTmax;
                    attribute redefines minimumWorkingTemperature = FMS_v1.loadcell.loadcellTmin;
                    }
            }
            satisfy requirements::MeasurementRequirement by FMS_v1{
                requirement MeasurementRequirement :>> requirements::MeasurementRequirement{
                    attribute redefines loadallowed = FMS_v1.num * FMS_v1.loadcell.loadcellCapacity;
                }
            }
            satisfy requirements::AccuracyRequirement by FMS_v1{
                requirement AccuracyRequirement :>> requirements::AccuracyRequirement{
                    attribute redefines AccuracyClassActual = FMS_v1.loadcell.loadcellAccuracyClass;
                }
            }
	 	}
    }

    package ActionTree{
        action provideEnergy:FMSActionDefinition::provideEnergy{
            
        }
        action ForceMeasurement:FMSActionDefinition::ForceMeasurement{
            
            action provideEnergy:FMSActionDefinition::provideEnergy;
			flow provideEnergy.voltageEnergy to ForceMeasurement.voltageEnergy;
			
        }
    }

    package requirements {
		
        requirement TemperatureRequirement: FMSRequirementDefinition::TemperatureRequirement{
            	doc /* The measuring system should run normally in certain temperature range.*/
		        attribute redefines maximumTemperature = 60['°C'];
		        attribute redefines minimumTemperature =-10['°C'];
        	}
        	
        	
        requirement MeasurementRequirement: FMSRequirementDefinition::MeasurementRequirement {
            doc /* The measuring system should provide a certain static measurement range in the direction of gravity and a certain dynamic measurement range. */
            
            attribute redefines staticLoadRequired =1000[N] ;
            attribute redefines dynamicLoadRequired =10[N];
            attribute loadallowed redefines LoadAllowed;
            require constraint {loadallowed>=staticLoadRequired+dynamicLoadRequired}
		    
        	}
        requirement AccuracyRequirement:FMSRequirementDefinition::AccuracyRequirement {
                doc /* The measuring system should provide a certain static measurement Accuracy. */
                attribute redefines AccuracyClass="C3";
                require constraint {AccuracyClass==AccuracyClassActual}
                }
    }
}