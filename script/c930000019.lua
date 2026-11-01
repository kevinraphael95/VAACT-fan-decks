--オレイカルコス・ミラー
--Orichalcos Mirror
local s,id=GetID()
function s.initial_effect(c)
	-- === AJOUT AUTO : considérée comme la carte officielle (ID 170000173) ===
	local e_add_code = Effect.CreateEffect(c)
	e_add_code:SetType(EFFECT_TYPE_SINGLE)
	e_add_code:SetCode(EFFECT_ADD_CODE)
	e_add_code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e_add_code:SetValue(170000173)
	c:RegisterEffect(e_add_code)
	-- =====================================================================
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.matgroup(e,tp)
	--Monstres de la main / du terrain utilisables comme matériaux (la carte elle-même est exclue)
	return Duel.GetRitualMaterial(tp):Filter(Card.IsMonster,e:GetHandler())
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		--Il faut un monstre à Invoquer, de la place, et des matériaux dont le total de Niveaux est de 6 ou plus
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and s.matgroup(e,tp):CheckWithSumGreater(Card.GetLevel,6)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--On crée le monstre Rituel (Mirror Knight Calling) depuis l'Extérieur du Duel (ID 930000020)
	local tc=Duel.CreateToken(tp,930000020)
	if not tc then return end

	--Vérification des matériaux (Niveau total 6 ou plus)
	local mg=s.matgroup(e,tp)
	if not mg:CheckWithSumGreater(Card.GetRitualLevel,6,tc) then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local mat=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,6,tc)

	if #mat>0 then
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()

		--Invoque la carte créée
		if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end