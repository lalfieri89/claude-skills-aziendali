---
name: gestione-test
description: Gestisce l'intero ciclo dei test per una classe Java Spring Boot. Analizza se esistono test, li genera se mancano, li revisiona se esistono, e alla fine indica i gap rimasti. Usare quando si vuole aggiungere o verificare i test di una classe esistente.
disable-model-invocation: true
argument-hint: "[percorso file opzionale]"
allowed-tools: Read Grep Glob Write
---

Analizza il file `$ARGUMENTS` (se non specificato, usa il file aperto nell'IDE).

Segui questo flusso in ordine:

---

## FASE 1 — Analisi iniziale

1. Leggi la classe sorgente per intero
2. Identifica il layer (Controller, Service, Repository, ecc.)
3. Elenca tutti i metodi pubblici con una breve descrizione
4. Cerca il file di test corrispondente in `src/test/java/` nello stesso package

---

## FASE 2 — Generazione test (se mancano o sono incompleti)

Se non esiste una classe di test o i test coprono meno del 70% dei metodi pubblici, genera i test mancanti.

**Stack obbligatorio in base al layer:**

- **Service** → `@ExtendWith(MockitoExtension.class)`, mock di tutti i repository e service iniettati
- **Controller** → `@WebMvcTest(NomeController.class)` + `MockMvc`, mock del service con `@MockBean`
- **Repository** → `@DataJpaTest`, database H2 in-memory, nessun mock

**Regole per i test:**

Per ogni metodo pubblico genera almeno 3 test:
1. **Happy path** — scenario normale con dati validi
2. **Edge case** — valore nullo, lista vuota, valore al limite
3. **Scenario di errore** — eccezione attesa, entità non trovata, dati non validi

**Convenzione nomi metodi:**
`dovrebbe_[risultatoAtteso]_quando_[condizione]()`

**Struttura base:**
```java
@ExtendWith(MockitoExtension.class)
@DisplayName("Test di NomeClasse")
class NomeClasseTest {

    @Mock
    NomeDipendenza nomeDipendenza;

    @InjectMocks
    NomeClasse nomeClasse;

    @BeforeEach
    void setUp() {
        // inizializzazione dati di test
    }

    @Test
    @DisplayName("Dovrebbe restituire X quando Y")
    void dovrebbe_restituireX_quando_Y() {
        // Arrange
        // Act
        // Assert (usa AssertJ: assertThat(...))
    }
}
```

Scrivi il file generato in `src/test/java/` nel package corrispondente alla classe testata.

---

## FASE 3 — Revisione test esistenti

Se esistono già dei test, analizzane la qualità controllando:

1. **Copertura degli scenari** — tutti i metodi pubblici hanno almeno un test? Mancano edge case o scenari di errore?
2. **Qualità delle assertion** — le assertion verificano risultati reali? (no `assertTrue(true)`, no assert solo sul tipo)
3. **Uso corretto dei mock** — i mock simulano comportamenti realistici? Non si sta testando l'implementazione invece del comportamento?
4. **Isolamento** — ogni test è indipendente dagli altri? Dipendenze condivise gestite correttamente in `@BeforeEach`?
5. **Naming** — i nomi dei test descrivono chiaramente il comportamento atteso?
6. **Struttura Arrange-Act-Assert** — il corpo dei test è leggibile e ben organizzato?

Per ogni problema trovato:
- **Livello:** [CRITICO | ATTENZIONE | INFO]
- **Test:** nome del metodo di test
- **Problema:** descrizione in italiano
- **Soluzione:** come correggerlo con esempio

---

## FASE 4 — Gap analysis e riepilogo finale

Produci una tabella con la copertura finale:

| Metodo | Testato | Scenari coperti | Priorità gap |
|--------|---------|-----------------|--------------|
| nomeMetodo() | SI / NO | happy path, edge case | ALTA / MEDIA / BASSA |

**Priorità gap:**
- **ALTA** — logica di calcolo, validazione dati, operazioni critiche (es. salvataggi, calcoli finanziari)
- **MEDIA** — operazioni CRUD standard, mapping DTO
- **BASSA** — getter/setter semplici, utility di bassa complessità

**Stima effort** per colmare i gap rimanenti: S (< 1h), M (1-3h), L (> 3h)

Concludi con un **GIUDIZIO FINALE**: COPERTURA BUONA / COPERTURA PARZIALE / COPERTURA INSUFFICIENTE
