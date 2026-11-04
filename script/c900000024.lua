local s,id=GetID()
function s.initial_effect(c)
    -- Définir le type de carte : Magie d'Équipement
    c:SetType(TYPE_SPELL + TYPE_EQUIP)

    -- Effet d'équipement
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    -- Effet : Ne peut être équipé que sur un monstre Normal
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EQUIP_LIMIT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetValue(s.eqlimit)
    c:RegisterEffect(e2)

    -- Effet : Une fois par tour, détruire un monstre adverse avec une ATK supérieure sans calculer les dégâts
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)

    -- Effet : Si le monstre équipé doit être détruit ou retiré, envoyer cette carte au cimetière à la place
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_DESTROY_REPLACE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e4:SetRange(LOCATION_SZONE)
    e4:SetTarget(s.reptg)
    e4:SetOperation(s.repop)
    c:RegisterEffect(e4)
end

-- Fonction pour limiter l'équipement aux monstres Normaux
function s.eqlimit(e,c)
    return c:IsType(TYPE_NORMAL)
end

-- Fonction cible pour l'équipement
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsType(TYPE_NORMAL) end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

-- Fonction d'opération pour l'équipement
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Equip(tp,c,tc)
    end
end

-- Fonction cible pour détruire un monstre adverse avec une ATK supérieure
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ec=e:GetHandler():GetEquipTarget()
    if chk==0 then
        return ec and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil,
            function(c) return c:GetAttack() > ec:GetAttack() end)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end

-- Fonction d'opération pour détruire un monstre adverse
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ec=c:GetEquipTarget()
    if not (c:IsRelateToEffect(e) and ec:IsFaceup()) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,
        function(c) return c:GetAttack() > ec:GetAttack() end)
    if #g>0 then
        Duel.Destroy(g:GetFirst(),REASON_EFFECT)
    end
end

-- Fonction cible pour remplacer la destruction du monstre équipé
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local ec=c:GetEquipTarget()
    if chk==0 then return c:IsAbleToGrave() and ec and ec==Duel.GetAttacker() and ec:IsReason(REASON_DESTROY) end
    return Duel.SelectEffectYesNo(tp,c,96)
end

-- Fonction d'opération pour envoyer la carte au cimetière à la place
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
