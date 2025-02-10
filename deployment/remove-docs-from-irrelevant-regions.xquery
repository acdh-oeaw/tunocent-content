xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $regionsToIgnore := ("Sousse")
let $teiDocsToIgnore := (
    db:open("vicav_lingfeatures")//tei:teiHeader/tei:profileDesc/tei:settingDesc/tei:place/tei:region[. = $regionsToIgnore]/ancestor::tei:TEI,
    db:open("vicav_corpus")//tei:teiHeader/tei:profileDesc/tei:settingDesc/tei:place/tei:region[. = $regionsToIgnore]/ancestor::tei:TEI,
    db:open("vicav_profiles")//tei:teiHeader/tei:profileDesc/tei:settingDesc/tei:place/tei:region[. = $regionsToIgnore]/ancestor::tei:TEI,
    db:open("vicav_samples")//tei:teiHeader/tei:profileDesc/tei:settingDesc/tei:place/tei:region[. = $regionsToIgnore]/ancestor::tei:TEI,
    db:open("vicav_texts")//tei:teiHeader/tei:profileDesc/tei:settingDesc/tei:place/tei:region[. = $regionsToIgnore]/ancestor::tei:TEI
)

return delete nodes $teiDocsToIgnore