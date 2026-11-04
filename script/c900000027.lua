local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon
    c:EnableReviveLimit()
    Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_NORMAL),1,4)

    -- Effet 1 (Continu) : Gagne 500 ATK/DEF pour chaque matériel
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.val)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2)

    -- Effet 2 (Ignition) : Détacher 1 matériel pour piocher, montrer, et potentiellement infliger des dégâts
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DRAW+CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCost(s.cost)
    e3:SetTarget(s.target)
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3)
end

-- Calcul du bonus d'ATK/DEF basé sur le nombre de matériels
function s.val(e,c)
    return c:GetOverlayCount()*500
end

-- Coût : Détacher 1 matériel
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- Cible de l'effet d'ignition
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

-- Opération : Piocher, révéler, et infliger des dégâts si c'est un monstre normal
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
        local tc=Duel.GetOperatedGroup():GetFirst()
        if tc then
            Duel.ConfirmCards(1-tp,tc)
            if tc:IsMonster() and tc:IsType(TYPE_NORMAL) then
                Duel.Damage(1-tp,1000,REASON_EFFECT)
            end
            Duel.ShuffleHand(tp)
        end
    end
end
