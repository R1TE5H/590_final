FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ src/
COPY docs/report.tex docs/report.tex

RUN apt-get update && apt-get install -y texlive-latex-base \
    && pdflatex docs/report.tex -output-directory=docs

RUN apt-get update && apt-get install -y doxygen graphviz

CMD ["python", "src/app.py"]
