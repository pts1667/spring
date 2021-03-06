/* This file is part of the Spring engine (GPL v2 or later), see LICENSE.html */
#include "MoveTypeFactory.h"
#include "MoveDefHandler.h"
#include "StrafeAirMoveType.h"
#include "HoverAirMoveType.h"
#include "GroundMoveType.h"
#include "StaticMoveType.h"
#include "ScriptMoveType.h"

#include "Sim/Units/Unit.h"
#include "Sim/Units/UnitDef.h"
#include "System/CompileSizeChecker.h"

void MoveTypeFactory::InitStatic() {
	CompileSizeChecker<CGroundMoveType, CStrafeAirMoveType>::MustBeGreaterThan();
	CompileSizeChecker<CGroundMoveType, CHoverAirMoveType>::MustBeGreaterThan();
	CompileSizeChecker<CGroundMoveType, CStaticMoveType>::MustBeGreaterThan();
	CompileSizeChecker<CGroundMoveType, CScriptMoveType>::MustBeGreaterThan();
}

AMoveType* MoveTypeFactory::GetMoveType(CUnit* unit, const UnitDef* ud) {
	CompileSizeChecker<CGroundMoveType, size_t, sizeof(CGroundMoveType), CUnit::amtMemBufferSize>::MustBeLessThan();
	CompileSizeChecker<CScriptMoveType, size_t, sizeof(CScriptMoveType), CUnit::smtMemBufferSize>::MustBeLessThan();

	if (ud->IsGroundUnit()) {
		// mobile ground-unit
		assert(!ud->canfly);
		assert(ud->pathType != -1u);
		assert(unit->moveDef == nullptr);

		unit->moveDef = moveDefHandler.GetMoveDefByPathType(ud->pathType);

		return (new (unit->amtMemBuffer) CGroundMoveType(unit));
	}

	if (ud->IsAirUnit()) {
		// mobile air-unit
		assert(ud->canfly);
		assert(ud->pathType == -1u);
		assert(unit->moveDef == nullptr);

		if (ud->IsStrafingAirUnit())
			return (new (unit->amtMemBuffer) CStrafeAirMoveType(unit));

		// flying builders, transports, gunships
		return (new (unit->amtMemBuffer) CHoverAirMoveType(unit));
	}

	// unit is immobile (but not necessarily a structure)
	assert(ud->IsImmobileUnit());
	return (new (unit->amtMemBuffer) CStaticMoveType(unit));
}

AMoveType* MoveTypeFactory::GetScriptMoveType(CUnit* unit) {
	return (new (unit->smtMemBuffer) CScriptMoveType(unit));
}

