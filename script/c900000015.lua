--Fusion au pif
-- MAGIE RAPIDE
-- Invoque par Fusion en utilisant 2 Monstres Normaux depuis la main et/ou le terrain
-- comme matériel, mais uniquement un Monstre Fusion qui partage le même Attribut
-- que l'un des deux monstres sacrifiés.

local s,id = GetID()

function s.initial_effect(c)
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

	-- Nécessaire pour que Duel.IsExistingFusionMaterial / SelectFusionMaterial fonctionnent
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_FUSION_MATERIAL)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	c:RegisterEffect(e2)
end

--------------------------------------------------
-- FILTRE : uniquement les Monstres Normaux, en main ou sur le terrain
--------------------------------------------------
function s.filter(c)
	return c:IsType(TYPE_NORMAL)
end

--------------------------------------------------
-- TARGET : vérifie qu'on a au moins 2 Monstres Normaux disponibles
-- ET qu'un Monstre Fusion valide existe (même Attribut qu'un des deux)
--------------------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,2,nil) then
			return false
		end
		return Duel.IsExistingFusionMaterial(tp,nil,2,2)
	end
end

--------------------------------------------------
-- OPERATION : sélection des 2 matériaux, puis choix restreint du Fusion
--------------------------------------------------
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- le joueur choisit 2 Monstres Normaux (main et/ou terrain) comme matériel
	local g = Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	if g:GetCount() < 2 then return end
	local mg = g:Select(tp,2,2,nil)
	if mg:GetCount() ~= 2 then return end

	-- on récupère les Attributs des deux monstres choisis
	local mc1 = mg:GetFirst()
	local mc2 = mg:GetNext()
	local attr1 = mc1:GetAttribute()
	local attr2 = mc2:GetAttribute()

	-- filtre du Monstre Fusion : doit partager l'Attribut de mc1 OU mc2
	local ffilter = function(fc)
		local fattr = fc:GetAttribute()
		return (fattr==attr1 or fattr==attr2) and fc:IsFusionSummonable()
	end

	-- Invocation Fusion classique, mais limitée aux Fusions correspondant au filtre
	Duel.SpecialSummonComplete()
	Duel.SendtoGrave(mg,REASON_MATERIAL+REASON_FUSION)
	local fc = Duel.SelectFusionCard(tp,ffilter)
	if fc then
		Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	end
end
