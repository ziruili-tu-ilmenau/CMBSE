package PartInstantiation {
    doc /* Question whether a part instantiation choice is modeled correctly.
    Each part instance can have different attribute values. */

    part def BatteryPack;

    part powerSystem {
        part batteryPacks : BatteryPack {
            doc /* Defines that we can either 1, 2 or 4 battery packs.
            This example seems unrealistic of course, but the fact that we
            cannot have 3 packs means that we cannot use the [1..4] notation. */
            attribute nPacks : ScalarValues::Positive = (1, 2, 4);
            multiplicity [nPacks];

            attribute storedEnergy : ISQ::EnergyValue;
        }
    }

    part twoPackPowerSystem subsets powerSystem {
        doc /* System with 2 battery packs,
        each of which have different amounts of stored energy. */

        part batteryPacks[2] subsets batteryPacks;
        
        part batteryPack1 references batteryPacks = batteryPacks#(1) {
            attribute redefines storedEnergy = 1000[SI::J];
            // attribute storedEnergy subsets storedEnergy = 1000[SI::J]; // Alternative notation?
        }

        // Is this equivalent to    "part batteryPack2 references batteryPacks = batteryPacks#(2) {""    ?
        part batteryPack2 = batteryPacks#(2) {
            attribute redefines storedEnergy = 2000[SI::J];
        }
    }

}
