import java.io.*;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

public class DumpComparator {

    private static class Dump {

        private static final String MAPPING_FILE = "methods.txt";

        private final File dir;
        private final HashMap<String, String> mapping;
        private final String graphFile;

        Dump(String dirPath, String graphFile) {
            dir = new File (dirPath);
            this.graphFile = graphFile + ".txt";
            mapping = new HashMap<>();
            initMapping();
        }

        private void initMapping() {
            try (Scanner scanner = new Scanner(new File(dir, MAPPING_FILE))) {
                while (scanner.hasNext()) {
                    String line = scanner.nextLine();
                    if (line.startsWith("com.oracle.svm")) {
                        continue;
                    }
                    String[] parts = line.split(" -> ");
                    mapping.put(parts[0], parts[1]);
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        private void compare(Dump other, String outputPath) {
            try (PrintWriter writer = new PrintWriter(outputPath)) {
                for (Map.Entry<String, String> myEntry : mapping.entrySet()) {
                    if (!other.mapping.containsKey(myEntry.getKey())) {
                        writer.println(myEntry.getKey());
                        writer.println(">>> used");
                        writer.println("<<< unused");
                        continue;
                    }
                    String myFile = myEntry.getValue() + "/" + graphFile;
                    String otherFile = other.mapping.get(myEntry.getKey()) + "/" + graphFile;
                    try (Scanner m1 = new Scanner(getChildFile(myFile));
                         Scanner m2 = new Scanner(other.getChildFile(otherFile))) {
                        int line = 0;
                        while (m1.hasNext() || m2.hasNext()) {
                            String l1 = safeNextLine(m1);
                            String l2 = safeNextLine(m2);
                            if (!l1.equals(l2)) {
                                writer.println(myEntry.getKey());
                                writer.println("line " + line + ":");
                                writer.println(">>> " + l1);
                                writer.println("<<< " + l2);
                                break;
                            }
                            line++;
                        }
                    }
                }
                for (Map.Entry<String, String> otherEntry : other.mapping.entrySet()) {
                    if (!mapping.containsKey(otherEntry.getKey())) {
                        writer.println(otherEntry.getKey());
                        writer.println(">>> unused");
                        writer.println("<<< used");
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        private static String safeNextLine(Scanner scanner) {
            if (scanner.hasNext()) {
                return scanner.nextLine();
            }
            return "EOF";
        }

        private File getChildFile(String relativePath) {
            return new File(dir, relativePath);
        }
    }

    public static void main(String[] args) {
        Dump d1 = new Dump(args[0], args[3]);
        Dump d2 = new Dump(args[1], args[3]);
        d1.compare(d2, args[2]);
    }
}