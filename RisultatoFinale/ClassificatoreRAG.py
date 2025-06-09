import os
import json
import glob
from datetime import datetime

class ReportScorer:
    """Assegna un punteggio unico a ciascun file di report JSON"""
    
    def __init__(self, report_dir: str, output_dir: str = None):
        """
        Inizializza il valutatore di report
        
        Args:
            report_dir: Directory contenente i file di report JSON
            output_dir: Directory di output per il report di valutazione (se diversa da report_dir)
        """
        self.report_dir = report_dir
        self.output_dir = output_dir if output_dir else report_dir
        
    def find_reports(self):
        """Trova tutti i file JSON di report nella directory specificata"""
        pattern = os.path.join(self.report_dir, "riepilogo_finale_*.json")
        return glob.glob(pattern)
    
    def calculate_score(self, report_data):
        """
        Calcola un punteggio unico per un report basato sulle sue summary variables
        
        La formula di punteggio è:
        score = (success_rate * 30) + (similarity_weight * 30) + (speed_weight * 20) + (token_weight * 20)
        
        Dove:
        - success_rate = passed / (passed + failed)
        - similarity_weight = average_similarity * 1.0
        - speed_weight = 1 / (1 + average_duration) (normalizzato per dare punteggio più alto a tempi più bassi)
        - token_weight = 1 / (1 + (average_tokens / 1000)) (normalizzato per dare punteggio più alto a meno token)
        
        Args:
            report_data: Dati JSON del report
            
        Returns:
            float: Punteggio finale da 0 a 100
        """
        # Estrai variabili di riepilogo
        passed = report_data.get('passed', 0)
        failed = report_data.get('failed', 0)
        avg_duration = report_data.get('average_duration', float('inf'))
        avg_tokens = report_data.get('average_tokens', float('inf'))
        avg_similarity = report_data.get('average_similarity', 0)
        
        # Calcola i pesi
        total_tests = passed + failed
        success_rate = passed / max(1, total_tests)
        
        # Normalizza la similarità (già tra 0 e 1)
        similarity_weight = avg_similarity
        
        # Normalizza la durata (più bassa è meglio)
        # Questa formula dà un valore tra 0 e 1, con 1 per durata = 0
        speed_weight = 1 / (1 + avg_duration)
        
        # Normalizza i token (più bassi è meglio)
        # Questa formula dà un valore tra 0 e 1, con 1 per token = 0
        token_weight = 1 / (1 + (avg_tokens / 1000))
        
        # Calcola il punteggio finale (massimo 100)
        score = (success_rate * 40) + (similarity_weight * 40) + (speed_weight * 10) + (token_weight * 10)
        
        return score
    
    def process_reports(self):
        """
        Processa tutti i report trovati, calcola un punteggio per ciascuno
        e genera un report di valutazione
        
        Returns:
            str: Percorso del file di report generato
        """
        report_files = self.find_reports()
        
        if not report_files:
            print(f"Nessun report trovato in {self.report_dir}")
            return None
            
        print(f"Trovati {len(report_files)} report da analizzare")
        
        # Lista per memorizzare i risultati
        results = []
        
        # Processa ogni file di report
        for file_path in report_files:
            try:
                filename = os.path.basename(file_path)
                with open(file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                
                # Calcola il punteggio
                score = self.calculate_score(data)
                
                # Estrai il timestamp dal nome del file o dal contenuto
                #timestamp = data.get('timestamp', filename.replace('riepilogo_finale_', '').replace('.json', ''))
                
                # Aggiungi ai risultati
                results.append({
                    'file': filename,
                    #'timestamp': timestamp,
                    'score': score,
                    'passed': data.get('passed', 0),
                    'failed': data.get('failed', 0),
                    'avg_duration': data.get('average_duration', 0),
                    'avg_tokens': data.get('average_tokens', 0),
                    'avg_similarity': data.get('average_similarity', 0)
                })
                
                print(f"Report {filename}: Punteggio {score:.2f}/100")
                
            except Exception as e:
                print(f"Errore nell'analisi del file {file_path}: {e}")
        
        # Ordina i risultati per punteggio (decrescente)
        results.sort(key=lambda x: x['score'], reverse=True)
        
        # Genera il report di valutazione
        return self.generate_report(results)
    
    def generate_report(self, results):
        """
        Genera un report di valutazione in formato testo e JSON
        
        Args:
            results: Lista di risultati di valutazione
            
        Returns:
            str: Percorso del file di report generato
        """
        now = datetime.now().strftime('%Y%m%d_%H%M%S')
        report_json_path = os.path.join(self.output_dir, f"valutazione_report_{now}.json")
           
        # Crea report JSON
        report_data = {
            'timestamp': now,
            'formula': {
                'success_rate_weight': 40,
                'similarity_weight': 30,
                'speed_weight': 20,
                'token_weight': 10
            },
            'results': results
        }
        
        with open(report_json_path, 'w', encoding='utf-8') as f:
            json.dump(report_data, f, indent=4)
        
        print(f"Report JSON generato in: {report_json_path}")
        
        return report_json_path

def main():
    """Punto di ingresso principale"""
    # Percorso alla directory contenente i report
    report_dir = input("Inserisci il percorso alla directory dei report (default: ./output_multipli): ").strip()
    if not report_dir:
        report_dir = "/home/valentina.coppi@scao.locale/Documents/Repo/Chatbot/Test/Chat/output_multipli"
    
    # Crea il valutatore
    scorer = ReportScorer(report_dir)
    
    # Processa i report e genera il report di valutazione
    scorer.process_reports()

# Esecuzione diretta delle funzioni
if __name__ == "__main__":
    # Definisci il percorso della directory dei report (cambia questo percorso se necessario)
    report_directory = "/home/valentina.coppi@scao.locale/Documents/Repo/Chatbot/Test/Chat/output_multipli"
    
    print(f"Avvio analisi dei report nella directory: {report_directory}")
    
    # Crea il valutatore
    scorer = ReportScorer(report_directory)
    
    # Processa i report e genera il report di valutazione
    output_path = scorer.process_reports()
    
    if output_path:
        print(f"Valutazione completata. Report salvato in: {output_path}")
    else:
        print("La valutazione non è stata completata a causa di errori.")
