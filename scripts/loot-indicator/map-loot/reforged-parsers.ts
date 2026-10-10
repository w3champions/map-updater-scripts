import BinaryStream from "mdx-m3-viewer-th/dist/cjs/common/binarystream.js";
import War3MapW3i from "mdx-m3-viewer-th/dist/cjs/parsers/w3x/w3i/file.js";
import Player from "mdx-m3-viewer-th/dist/cjs/parsers/w3x/w3i/player.js";
import Force from "mdx-m3-viewer-th/dist/cjs/parsers/w3x/w3i/force.js";
import UpgradeAvailabilityChange from "mdx-m3-viewer-th/dist/cjs/parsers/w3x/w3i/upgradeavailabilitychange.js";
import TechAvailabilityChange from "mdx-m3-viewer-th/dist/cjs/parsers/w3x/w3i/techavailabilitychange.js";
import RandomUnitTable from "mdx-m3-viewer-th/dist/cjs/parsers/w3x/w3i/randomunittable.js";
import RandomItemTable from "mdx-m3-viewer-th/dist/cjs/parsers/w3x/w3i/randomitemtable.js";
import UnitsDoo from "mdx-m3-viewer-th/dist/cjs/parsers/w3x/unitsdoo/file.js";
import Unit from "mdx-m3-viewer-th/dist/cjs/parsers/w3x/unitsdoo/unit.js";
import DroppedItemSet from "mdx-m3-viewer-th/dist/cjs/parsers/w3x/unitsdoo/droppeditemset.js";
import InventoryItem from "mdx-m3-viewer-th/dist/cjs/parsers/w3x/unitsdoo/inventoryitem.js";
import ModifiedAbility from "mdx-m3-viewer-th/dist/cjs/parsers/w3x/unitsdoo/modifiedability.js";
import RandomUnit from "mdx-m3-viewer-th/dist/cjs/parsers/w3x/unitsdoo/randomunit.js";

// mdx-m3-viewer-th (latest 5.13.4) only understands the formats written up to
// the 2.0 World Editor. The 3.0 editor (editor versions 7000 and 7003) saves
// war3map.w3i as version 39 and war3mapUnits.doo as version 13. The classes
// below hand every older version to the library unchanged and only read the
// new versions themselves. Field order follows HiveWE's map_info and units
// readers, and was checked byte for byte against maps saved by both editors.

const W3I_REFORGED_3 = 39;
const UNITS_DOO_LEGACY_MAX = 8;
const UNITS_DOO_REFORGED_3 = 13;

// Each light attached to a unit or doodad since units.doo version 13:
// index, isShadowCasting, color (4 bytes) and six floats.
const LIGHT_BYTE_LENGTH = 36;

export class War3MapW3iReforged extends War3MapW3i {
    /** @since 39 */
    loadingScreenSource = 0;
    /** @since 39, read between globalWeather and soundEnvironment */
    fogExtra = new Uint8Array(24);
    /** @since 39, ten water settings read after the camera zoom */
    waterExtra = new Int32Array(10);

    load(buffer: ArrayBuffer | Uint8Array) {
        const version = new BinaryStream(buffer).readInt32();
        if (version < W3I_REFORGED_3) {
            super.load(buffer);
            return;
        }
        if (version > W3I_REFORGED_3) {
            // A newer layout would be misread silently and drop loot data, so
            // fail the build instead.
            throw new Error(`war3map.w3i version ${version} is not supported (max ${W3I_REFORGED_3}). Extend reforged-parsers.ts for the new editor format.`);
        }

        const stream = new BinaryStream(buffer);
        this.version = stream.readInt32();
        this.saves = stream.readInt32();
        this.editorVersion = stream.readInt32();
        stream.readUint32Array(this.buildVersion);
        this.name = stream.readNull();
        this.author = stream.readNull();
        this.description = stream.readNull();
        this.recommendedPlayers = stream.readNull();
        stream.readFloat32Array(this.cameraBounds);
        stream.readInt32Array(this.cameraBoundsComplements);
        stream.readInt32Array(this.playableSize);
        this.flags = stream.readUint32();
        this.tileset = stream.readBinary(1);
        this.campaignBackground = stream.readInt32();
        this.loadingScreenSource = stream.readInt32();
        this.loadingScreenModel = stream.readNull();
        this.loadingScreenText = stream.readNull();
        this.loadingScreenTitle = stream.readNull();
        this.loadingScreenSubtitle = stream.readNull();
        this.loadingScreen = stream.readInt32();
        this.prologueScreenModel = stream.readNull();
        this.prologueScreenText = stream.readNull();
        this.prologueScreenTitle = stream.readNull();
        this.prologueScreenSubtitle = stream.readNull();
        this.useTerrainFog = stream.readInt32();
        stream.readFloat32Array(this.fogHeight);
        this.fogDensity = stream.readFloat32();
        stream.readUint8Array(this.fogColor);
        this.globalWeather = stream.readInt32();
        stream.readUint8Array(this.fogExtra);
        this.soundEnvironment = stream.readNull();
        this.lightEnvironmentTileset = stream.readBinary(1);
        stream.readUint8Array(this.waterVertexColor);
        this.scriptMode = stream.readUint32();
        this.graphicsMode = stream.readUint32();
        this.unknown1 = stream.readUint32();
        this.defaultCameraZoom = stream.readUint32();
        this.maxCameraZoom = stream.readUint32();
        this.minCameraZoom = stream.readUint32();
        stream.readInt32Array(this.waterExtra);

        // Player.load has no slot for the HUD skin that version 39 stores
        // between the race and the fixed start position.
        for (let i = 0, l = stream.readInt32(); i < l; i++) {
            const player = new Player();
            player.id = stream.readInt32();
            player.type = stream.readInt32();
            player.race = stream.readInt32();
            stream.readInt32(); // HUD skin
            player.isFixedStartPosition = stream.readInt32();
            player.name = stream.readNull();
            stream.readFloat32Array(player.startLocation);
            player.allyLowPriorities = stream.readUint32();
            player.allyHighPriorities = stream.readUint32();
            stream.readUint8Array(player.unknown1);
            this.players[i] = player;
        }

        for (let i = 0, l = stream.readInt32(); i < l; i++) {
            const force = new Force();
            force.load(stream);
            this.forces[i] = force;
        }
        for (let i = 0, l = stream.readInt32(); i < l; i++) {
            const change = new UpgradeAvailabilityChange();
            change.load(stream);
            this.upgradeAvailabilityChanges[i] = change;
        }
        for (let i = 0, l = stream.readInt32(); i < l; i++) {
            const change = new TechAvailabilityChange();
            change.load(stream);
            this.techAvailabilityChanges[i] = change;
        }
        for (let i = 0, l = stream.readInt32(); i < l; i++) {
            const table = new RandomUnitTable();
            table.load(stream);
            this.randomUnitTables[i] = table;
        }
        for (let i = 0, l = stream.readInt32(); i < l; i++) {
            const table = new RandomItemTable();
            table.load(stream);
            this.randomItemTables[i] = table;
        }
    }
}

export class War3MapUnitsDooReforged extends UnitsDoo {
    load(buffer: ArrayBuffer | Uint8Array, buildVersion: number) {
        const stream = new BinaryStream(buffer);
        if (stream.readBinary(4) !== "W3do") {
            throw new Error("Not a valid war3mapUnits.doo buffer");
        }
        const version = stream.readInt32();
        if (version <= UNITS_DOO_LEGACY_MAX) {
            super.load(buffer, buildVersion);
            return;
        }
        if (version !== UNITS_DOO_REFORGED_3) {
            throw new Error(`war3mapUnits.doo version ${version} is not supported (expected <= ${UNITS_DOO_LEGACY_MAX} or ${UNITS_DOO_REFORGED_3}). Extend reforged-parsers.ts for the new editor format.`);
        }

        this.version = version;
        this.subversion = stream.readUint32();
        for (let i = 0, l = stream.readInt32(); i < l; i++) {
            this.units[i] = loadUnitV13(stream, this.subversion, buildVersion);
        }
    }
}

/**
 * Unit.load plus the fields version 13 adds: a group id after the skin, and
 * roll, pitch and a list of lights after the creation number.
 */
function loadUnitV13(stream: BinaryStream, subversion: number, buildVersion: number): Unit {
    const unit = new Unit();
    unit.id = stream.readBinary(4);
    unit.variation = stream.readInt32();
    stream.readFloat32Array(unit.location);
    unit.angle = stream.readFloat32();
    stream.readFloat32Array(unit.scale);
    if (buildVersion > 131) {
        unit.skin = stream.readBinary(4);
    }
    stream.readInt32(); // group id
    unit.flags = stream.readUint8();
    unit.player = stream.readInt32();
    unit.unknown = stream.readUint16();
    unit.hitpoints = stream.readInt32();
    unit.mana = stream.readInt32();
    if (subversion > 10) {
        unit.droppedItemTable = stream.readInt32();
    }
    for (let i = 0, l = stream.readInt32(); i < l; i++) {
        const set = new DroppedItemSet();
        set.load(stream);
        unit.droppedItemSets[i] = set;
    }
    unit.goldAmount = stream.readInt32();
    unit.targetAcquisition = stream.readFloat32();
    unit.heroLevel = stream.readInt32();
    if (subversion > 10) {
        unit.heroStrength = stream.readInt32();
        unit.heroAgility = stream.readInt32();
        unit.heroIntelligence = stream.readInt32();
    }
    for (let i = 0, l = stream.readInt32(); i < l; i++) {
        const item = new InventoryItem();
        item.load(stream);
        unit.itemsInInventory[i] = item;
    }
    for (let i = 0, l = stream.readInt32(); i < l; i++) {
        const ability = new ModifiedAbility();
        ability.load(stream);
        unit.modifiedAbilities[i] = ability;
    }
    unit.randomFlag = stream.readInt32();
    if (unit.randomFlag === 0) {
        stream.readUint8Array(unit.level); // 24bit number
        unit.itemClass = stream.readUint8();
    } else if (unit.randomFlag === 1) {
        unit.unitGroup = stream.readUint32();
        unit.positionInGroup = stream.readUint32();
    } else if (unit.randomFlag === 2) {
        for (let i = 0, l = stream.readInt32(); i < l; i++) {
            const randomUnit = new RandomUnit();
            randomUnit.load(stream);
            unit.randomUnitTables[i] = randomUnit;
        }
    }
    unit.customTeamColor = stream.readInt32();
    unit.waygate = stream.readInt32();
    unit.creationNumber = stream.readInt32();
    stream.readFloat32(); // roll
    stream.readFloat32(); // pitch
    // The light list is variable length, so it has to be walked even though
    // the loot indicator does not use it.
    stream.skip(stream.readInt32() * LIGHT_BYTE_LENGTH);
    return unit;
}
