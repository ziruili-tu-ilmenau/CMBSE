package LoadCellModel{
    import LoadCellDefinition::*;
    package PartsTree{
        part LoadCell_v1 : LoadCellDefinition::'Load Cell Part Definition'::loadcell{
            attribute :>>weight =2[kg];
            
            attribute :>>Tmax=60['°C'];
          
            attribute :>>Tmin=-10['°C'];
            
            attribute :>>Tamax=65['°C'];
            
            attribute :>>Tamin=-15['°C'];
            
            attribute :>>maximumCapacity=40[kg];
            
            attribute :>>maintenanceTime=4000[h]; 
            
            attribute :>>inputvoltage=12[V];
            
            attribute :>>AccuracyClass="C3";		 	
	     	
	 		part StrainGauge_v1: LoadCellDefinition::'Load Cell Part Definition'::StrainGauge{
	 			attribute :>>Material="Aluminium";
	 		}
            perform ActionTree::ForceMeasurement_loadcell redefines ForceMeasurement_loadcell;
            port measuringInfoPort: MeasuringInfoPort ;
            satisfy requirements::TemperatureRequirement by LoadCell_v1{
                attribute redefines maximumWorkingTemperature = LoadCell_v1.Tmax;
                attribute redefines minimumWorkingTemperature = LoadCell_v1.Tmin;
                attribute redefines temperatureActual=LoadCell_v1.temperaturePort.Roomtemperature;
            }
            satisfy requirements::MeasurementRequirement by LoadCell_v1{
                attribute redefines  staticLoadAllowed = LoadCell_v1.maximumCapacity;
            }
            satisfy requirements::AccuracyRequirement by LoadCell_v1{
                    requirement AccuracyRequirement :>> requirements::AccuracyRequirement{
                        attribute redefines AccuracyClassActual = LoadCell_v1.AccuracyClass;
                    }
        }
    }
    }
    package ActionTree{
        action ForceMeasurement_loadcell:'Load Cell Action Definition'::ForceMeasurement_loadcell{
            action ResultConvert:'Load Cell Action Definition'::ResultConvert;
            action ForceToVoltage:'Load Cell Action Definition'::ForceToVoltage;
            flow ForceToVoltage.MessData to ResultConvert.MessData;
            flow ResultConvert.messresult to ForceMeasurement_loadcell.messresult;
        }
    }
    package requirements{
        requirement TemperatureRequirement: 'Requirement Definition'::Temperature{
            
            	doc /* The measuring system should run normally in certain temperature range.*/
		        attribute redefines maximumTemperature =60['°C'];
		        attribute redefines minimumTemperature=-10['°C'];
		        attribute redefines minimumWorkingTemperature;
		        attribute redefines maximumWorkingTemperature;
		        attribute redefines temperatureActual;
		        
		        require constraint {maximumTemperature>=temperatureActual}
		        require constraint {temperatureActual>=minimumTemperature}
		        
        	}
        	
        	
        requirement MeasurementRequirement: 'Requirement Definition'::MeasurementRequirement {
            doc /* The measuring system should provide a certain static measurement range in the direction of gravity and a certain dynamic measurement range. */
            
            attribute redefines staticLoadRequired =35[kg] ;
            attribute redefines dynamicLoadRequired =1[kg];
            attribute redefines staticLoadAllowed{}
            require constraint {staticLoadAllowed>=staticLoadRequired+dynamicLoadRequired}
		   
        	}
        requirement  AccuracyRequirement:'Requirement Definition'::AccuracyRequirement{
            doc /* The load cell should provide a certain static measurement Accuracy. */
                attribute redefines AccuracyClass="C3";
                require constraint {AccuracyClass==AccuracyClassActual}
            }
    }
}