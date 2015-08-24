package hyphenation;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Stack;

import javax.xml.parsers.SAXParserFactory;

import static com.google.common.base.Predicates.instanceOf;
import static com.google.common.collect.Iterables.find;

import org.daisy.pipeline.braille.common.Hyphenator;
import org.daisy.pipeline.braille.common.Transform;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.dispatch;
import org.daisy.pipeline.braille.libhyphen.LibhyphenHyphenator;

import static org.junit.Assert.assertEquals;
import org.junit.Test;

import org.ops4j.pax.exam.util.PathUtils;

import org.osgi.framework.BundleContext;
import static org.osgi.framework.FrameworkUtil.getBundle;
import org.osgi.framework.InvalidSyntaxException;
import org.osgi.framework.ServiceReference;

import org.xml.sax.Attributes;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;

public class test_nl {
	
	@Test
	public void testDutchHyphenation() throws Exception {
		Transform.Provider<LibhyphenHyphenator> provider = getProvider(LibhyphenHyphenator.class, LibhyphenHyphenator.Provider.class);
		Hyphenator hyphenator = provider.get("(locale:nl)").iterator().next();
		XMLReader reader = SAXParserFactory.newInstance().newSAXParser().getXMLReader();
		reader.setContentHandler(new DefaultHandler() {
			Stack<String> elements = new Stack<String>();
			String input = null;
			String expect = null;
			@Override
			public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException {
				elements.push(qName);
				if ("entry".equals(qName)) {
					input = null;
					expect = null; }
			}
			@Override
			public void endElement(String uri, String localName, String qName) throws SAXException {
				elements.pop();
				if ("entry".equals(qName))
					assertEquals(expect, input);
			}
			@Override
			public void characters(char ch[], int start, int length) throws SAXException {
				String text = new String(ch, start, length);
				if ("input".equals(elements.peek()))
					input = text;
				else if ("expect".equals(elements.peek()))
					expect = text;
			}
		});
		File data = new File(new File(PathUtils.getBaseDir()), "src/resources/hyphenation/data_dutch.xml");
		reader.parse(data.toURI().toASCIIString());
	}
	
	private static BundleContext context = getBundle(test_nl.class).getBundleContext();
	
	private <T extends Transform> Transform.Provider<T> getProvider(Class<T> transformerClass, Class<? extends Transform.Provider<T>> providerClass) {
		List<Transform.Provider<T>> providers = new ArrayList<Transform.Provider<T>>();
		try {
			for (ServiceReference<? extends Transform.Provider<T>> ref : context.getServiceReferences(providerClass, null))
				providers.add(context.getService(ref)); }
		catch (InvalidSyntaxException e) {
			throw new RuntimeException(e); }
		return dispatch(providers);
	}
}
