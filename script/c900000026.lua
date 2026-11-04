--Un Xyz depuis la main ???
local s,id=GetID()
function s.initial_effect(c)
    -- Activer la carte
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Filtre pour vérifier si une carte est un monstre Normal dans la main
function s.normal_monster_filter(c,tp)
    return c:IsMonster() and c:IsType(TYPE_NORMAL) and c:IsDiscardable()
end

-- Filtre pour le monstre Xyz qu'on peut invoquer depuis l'Extra Deck
function s.xyz_filter(c,e,tp)
    local mg=Duel.GetMatchingGroup(s.normal_monster_filter,tp,LOCATION_HAND,0,nil,tp)
    -- Vérifie si le monstre Xyz peut être invoqué par son propre type d'invocation (ou si le simulateur autorise l'Xyz avec ces cartes)
    return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) 
        and c:CheckXyzMaterial(mg,nil,1,99,nil) -- Adapte selon le système d'EdoPro pour les matériels en main
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- On doit avoir au moins un monstre Xyz dans l'Extra Deck invocable
        -- et des monstres Normaux en main pour payer le coût/fournir les matériels
        return Duel.IsExistingMatchingCard(s.xyz_filter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Étape 1 : Choisir le monstre Xyz dans l'Extra Deck
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.xyz_filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    local xyz=g:GetFirst()
    if not xyz then return end

    -- Étape 2 : Récupérer les monstres Normaux de la main pour faire les matériels
    local mg=Duel.GetMatchingGroup(s.normal_monster_filter,tp,LOCATION_HAND,0,nil,tp)
    
    -- Utilisation des fonctions natives d'EdoPro pour gérer l'Xyz avec des cartes de la main
    -- (Le monstre Xyz doit accepter des matériels depuis la main si le script le permet, ou on applique les contraintes)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    -- On demande au joueur de sélectionner les monstres Normaux de sa main qui correspondent aux exigences du monstre Xyz
    if xyz:CheckXyzMaterial(mg,nil,1,99,nil) then
        local mat=Duel.SelectXyzMaterial(tp,xyz,mg,1,99,nil)
        if mat and #mat > 0 then
            -- On défausse les monstres Normaux sélectionnés de la main
            Duel.SendtoGrave(mat,REASON_EFFECT+REASON_DISCARD)
            -- On fixe les matériels sous le monstre Xyz et on l'invoque
            xyz:SetMaterial(mat)
            Duel.Overlay(xyz,mat)
            Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
            xyz:CompleteProcedure()
        end
    end
end
